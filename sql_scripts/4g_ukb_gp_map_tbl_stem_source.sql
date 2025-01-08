CREATE TABLE {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (LIKE {TARGET_SCHEMA}.STEM_SOURCE);

--insert into stem_source from temp_gp_scripts_2 --duplication exists
-- a GP can produce identical prescriptions intentionally, 
-- for example if a person needs to travel and requests extra medications or if the software system imposes restrictions on prescriptions. 
-- Identical prescription would give patients a longer exposure to the medication

WITH cte0 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select t3.*
	from {SOURCE_SCHEMA}.temp_visit_detail as t1 
	join cte0 as t2 on t1.person_id = t2.person_id
	join {TARGET_SCHEMA}.visit_detail as t3 on t1.visit_detail_id = t3.visit_detail_id
	where t1.source_table = 'Drug Prescription'
), base as(
	select 
		t1.eid, 
		t3.visit_occurrence_id,
		t3.visit_detail_id,
		t1.data_provider,
		t1.drug_name,
		t1.read_2,
		t1.issue_date,
		t1.quantity,
		t1.qty,
		t1.packsize,
		t1.daysupply,
		--min(t1.id) as id
		t1.id						--keep duplication in source date
	from {SOURCE_SCHEMA}.temp_gp_scripts_2 as t1
	join cte0 on eid = cte0.person_id
	join {SOURCE_SCHEMA}.lookup626 as lkup on lkup.code = t1.data_provider
	join {TARGET_SCHEMA}.observation_period as t2 on t1.eid = t2.person_id
	join cte1 as t3 on t3.person_id = t1.eid and t3.visit_detail_start_date = t1.issue_date and t3.visit_detail_source_value = concat(lkup.description, '-Drug Prescription')
	where t1.issue_date >= t2.observation_period_start_date and t1.issue_date <= t2.observation_period_end_date
	--group by t1.eid, t3.visit_occurrence_id, t3.visit_detail_id, t1.data_provider, t1.drug_name, t1.read_2, t1.issue_date, t1.quantity, t1.qty, t1.packsize, t1.daysupply
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id, 
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	days_supply,
	sig,
	unit_source_value,
	quantity,
	stem_source_table,
	stem_source_id
)
select distinct				--remove duplication by 1:n mappings in source_to_standard_vocab_map
	t1.eid, 	
	t1.visit_occurrence_id,
	t1.visit_detail_id,
	COALESCE(t2.source_code, t3.source_code, t1.drug_name, t1.read_2) as source_value, 
	0 as source_concept_id,
	32817 as type_concept_id,
	t1.issue_date,
	t1.issue_date,
	'00:00:00'::time start_time,
	t1.daysupply,
	t1.quantity as sig, --Drug
	(regexp_match(t1.quantity, '[^.\d]+.*'))[1] as unit_source_value, --Device
	t1.qty as quantity,
	'gp_scripts' as stem_source_table,
	t1.id as stem_source_id
from base as t1
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on UPPER(t1.drug_name) = UPPER(t2.source_code) and t2.source_vocabulary_id = 'UKB_GP_SCRIPT_DRUG_STCM'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on LEFT(t1.read_2, 5) = t3.source_code and t3.source_vocabulary_id = 'UKB_GP_SCRIPT_READ_STCM';

----------------
-- gp_clinical--  **no duplication
----------------
--insert into stem_source from gp_clinical
--read_3 is not null 
--have value1 ONLY
--no operator

WITH cte0 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select t3.*
	from {SOURCE_SCHEMA}.temp_visit_detail as t1 
	join cte0 as t2 on t1.person_id = t2.person_id
	join {TARGET_SCHEMA}.visit_detail as t3 on t1.visit_detail_id = t3.visit_detail_id
	where t1.source_table = 'Clinical'
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id, 
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	unit_source_value,
	stem_source_table,
	stem_source_id
)
select distinct
	t1.eid, 
	t3.visit_occurrence_id,
	t3.visit_detail_id,
	COALESCE(t4.source_code, t5.source_code, t1.read_3) as source_value, 
	COALESCE(t4.source_concept_id, t5.source_concept_id, 0) as source_concept_id,
	32817 as type_concept_id,
	t1.event_dt,
	t1.event_dt,
	'00:00:00'::time start_time,
	t1.value1::numeric as value_as_number,
	CASE 
		WHEN t1.read_3 = '22A..' THEN 'kg'								
		WHEN t1.read_3 = '229..' and t1.value1::numeric < 10 THEN 'meters'   
		WHEN t1.read_3 = '229..' and t1.value1::numeric > 10 THEN 'cm'  
		WHEN t1.read_3 in ('XaEOV', 'XaEOZ') THEN 'mmol/L'
		ELSE null
	END as unit_source_value,
	'gp_clinical' as stem_source_table,
	t1.id as stem_source_id
from {SOURCE_SCHEMA}.gp_clinical as t1
join cte0 on t1.eid = cte0.person_id
join {SOURCE_SCHEMA}.lookup626 as lkup on lkup.code = t1.data_provider
join {TARGET_SCHEMA}.observation_period as t2 on t1.eid = t2.person_id
join cte1 as t3 on t3.person_id = t1.eid and t3.visit_detail_start_date = t1.event_dt and t3.visit_detail_source_value = concat(lkup.description, '-Clinical')
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.read_3 = t4.source_code and t4.source_vocabulary_id = 'UKB_GP_CLINICAL_READ_STCM'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t5 on concat(t1.read_3, '00') = t5.source_code and t5.source_vocabulary_id = 'Read'
where t1.event_dt >= t2.observation_period_start_date and t1.event_dt <= t2.observation_period_end_date
and t1.read_3 is not null; 

----read_2 is not null

-- drug_allergy
-- (gemscript code -> value_as_concept_id, allergy(RCT00X) -> value_as_string, severity -> qualifier_source_concept + qualifier_concept_id)
WITH cte0 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select t3.*
	from {SOURCE_SCHEMA}.temp_visit_detail as t1 
	join cte0 as t2 on t1.person_id = t2.person_id
	join {TARGET_SCHEMA}.visit_detail as t3 on t1.visit_detail_id = t3.visit_detail_id
	where t1.source_table = 'Clinical'
), _qualifier AS(
	select * FROM (VALUES 
		('SEV001', 4114688),	-- Minimal
		('SEV002', 4116992),	-- Mild
		('SEV003', 37165778),	-- Moderate
		('SEV004', 4087703),	-- Severe
		('SEV005', 763690), 	-- Very severe
		('SEV006', 0) 			-- Potentially Fatal
	)AS t (_qualifier, _target_concept_id)		
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id, 
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_string,
	value_as_concept_id,
	qualifier_source_value,
	qualifier_concept_id,
	stem_source_table,
	stem_source_id
)
select distinct
	t1.eid, 
	t3.visit_occurrence_id,
	t3.visit_detail_id,
	COALESCE(t4.source_code, t5.source_code, t1.read_2) as source_value, 
	COALESCE(t4.source_concept_id, t5.source_concept_id, 0) as source_concept_id,
	32817 as type_concept_id,
	t1.event_dt,
	t1.event_dt,
	'00:00:00'::time start_time,
	CASE 
		WHEN t1.value1 = 'RCT001' OR t1.value2 = 'RCT001' OR t1.value3 = 'RCT001' THEN 'Allergy'
		WHEN t1.value1 = 'RCT002' OR t1.value2 = 'RCT002' OR t1.value3 = 'RCT002' THEN 'Intolerance'
		WHEN t1.value1 = 'RCT003' OR t1.value2 = 'RCT003' OR t1.value3 = 'RCT003' THEN 'Adverse Effect'
	END AS value_as_string,	
	t7.concept_id as value_as_concept_id,
	t6._qualifier as qualifier_source_value,
	t6._target_concept_id as qualifier_concept_id,
	'gp_clinical' as stem_source_table,
	t1.id as stem_source_id
from {SOURCE_SCHEMA}.gp_clinical as t1
join cte0 on t1.eid = cte0.person_id
join {SOURCE_SCHEMA}.lookup626 as lkup on lkup.code = t1.data_provider
join {TARGET_SCHEMA}.observation_period as t2 on t1.eid = t2.person_id
join cte1 as t3 on t3.person_id = t1.eid and t3.visit_detail_start_date = t1.event_dt and t3.visit_detail_source_value = concat(lkup.description, '-Clinical')
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.read_2 = t4.source_code and t4.source_vocabulary_id = 'UKB_GP_CLINICAL_READ_STCM'
left join  {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t5 on concat(t1.read_2, '00') = t5.source_code and t5.source_vocabulary_id = 'Read'
left join _qualifier as t6 on t6._qualifier = t1.value1 or t6._qualifier = t1.value2 or t6._qualifier = t1.value3
left join {VOCABULARY_SCHEMA}.concept as t7 on (t7.concept_code = t1.value1 or t7.concept_code = t1.value2 or t7.concept_code = t1.value3) and t7.vocabulary_id = 'Gemscript'  
where t1.event_dt >= t2.observation_period_start_date and t1.event_dt <= t2.observation_period_end_date
and t1.read_2 is not null
and (t1.value1 ~ '^RCT00[0-3]$'  OR t1.value2 ~ '^RCT00[0-3]$'  OR t1.value3 ~ '^RCT00[0-3]$' );


-- with high and low range values 
WITH cte0 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select t3.*
	from {SOURCE_SCHEMA}.temp_visit_detail as t1 
	join cte0 as t2 on t1.person_id = t2.person_id
	join {TARGET_SCHEMA}.visit_detail as t3 on t1.visit_detail_id = t3.visit_detail_id
	where t1.source_table = 'Clinical'
), cte2 AS(
	SELECT t1.*,
		case when COALESCE((regexp_match(t1.value1, '^\d+[.]\d+|^\d+'))[1] = t1.value1, false) then 1 else 0 end as v1,
		case when COALESCE((regexp_match(t1.value2, '^\d+[.]\d+|^\d+'))[1] = t1.value2, false) then 1 else 0 end as v2,		
		case when COALESCE((regexp_match(t1.value3, '^\d+[.]\d+|^\d+'))[1] = t1.value3, false) then 1 else 0 end as v3
	from {SOURCE_SCHEMA}.gp_clinical as t1
	join cte0 as t2 on t1.eid = t2.person_id
), _read AS(
	SELECT * FROM (VALUES 
		('246..'),('2466.'),('2465.'),('2464.'),('2462.'),
		('2467.'),('2463.'),('2460.'),('2461.'),('2468.'),
		('246B.'),('246G.'),('246J.'),('6623.'),('662L.'),
		('246Z.'),('246F.'),('246L.'),('246K.'),('246A.'), 
		('2469.'),
		('246Y.'),('246V.'),('246X.'),('246W.'),('246D.'),
		('246Q.'),('246c.'),('246C.'),('246a.'),('246b.'),
		('246d.'),('246E.'),('246R.'),
		('246M.')--To-DO: athena maps to 0
	)AS t (_read_2)
), _operator AS(
	select * FROM (VALUES 
		('OPR001', 4171756),
		('OPR002', 4171754),
		('OPR003', 4172703),
		('OPR004', 4172704),
		('OPR005', 4171755),
		('OPR006', 0),
		('<', 4171756),
		('<=', 4171754),
		('=', 4172703),
		('>', 4172704),
		('>=', 4171755),
		('~', 0)
	)AS t (_operator, _target_concept_id)		
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id, 
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	value_as_string,
	range_low,
	range_high,
	operator_concept_id,
	unit_source_value,
	unit_source_concept_id,
	stem_source_table,
	stem_source_id
)
select distinct
	t1.eid, 
	t3.visit_occurrence_id,
	t3.visit_detail_id,
	COALESCE(t4.source_code, t5.source_code, t1.read_2) as source_value, 
	COALESCE(t4.source_concept_id, t5.source_concept_id, 0) as source_concept_id,
	32817 as type_concept_id,
	t1.event_dt,
	t1.event_dt,
	'00:00:00'::time start_time,
	CASE 
		WHEN (t1.v1+t1.v2+t1.v3) = 3 THEN t1.value3::numeric
		WHEN (t1.v1+t1.v2+t1.v3) = 1 AND t1.v1 = 1 THEN t1.value1::numeric
		WHEN (t1.v1+t1.v2+t1.v3) = 1 AND t1.v2 = 1 THEN t1.value2::numeric
		WHEN (t1.v1+t1.v2+t1.v3) = 1 AND t1.v3 = 1 THEN t1.value3::numeric
	END as value_as_number, 
	CASE 
		WHEN (t1.v1+t1.v2+t1.v3) = 2 AND t1.v1=0 THEN t1.value1
		WHEN (t1.v1+t1.v2+t1.v3) = 2 AND t1.v2=0 THEN t1.value2
		WHEN (t1.v1+t1.v2+t1.v3) = 2 AND t1.v3=0 THEN t1.value3
		WHEN (t1.v1+t1.v2+t1.v3) = 1 AND t6.source_code IS NOT NULL AND t1.v1 = 0 THEN t1.value1
		WHEN (t1.v1+t1.v2+t1.v3) = 1 AND t6.source_code IS NOT NULL AND t1.v1 = 1 THEN t1.value2
		WHEN (t1.v1+t1.v2+t1.v3) = 1 AND t1.v1 = 1 THEN COALESCE(t1.value2, t1.value3)
		WHEN (t1.v1+t1.v2+t1.v3) = 1 AND t1.v2 = 1 THEN COALESCE(t1.value1, t1.value3)
		WHEN (t1.v1+t1.v2+t1.v3) = 1 AND t1.v3 = 1 THEN COALESCE(t1.value1, t1.value2)		
	END as value_as_string,
	CASE
		WHEN (t1.v1+t1.v2+t1.v3) = 3 THEN LEAST(t1.value1::numeric, t1.value2::numeric) 
		WHEN (t1.v1+t1.v2+t1.v3) = 2 AND t1.v1 = 1 AND t1.v2 = 1 THEN LEAST(t1.value1::numeric, t1.value2::numeric) 
		WHEN (t1.v1+t1.v2+t1.v3) = 2 AND t1.v1 = 1 AND t1.v3 = 1 THEN LEAST(t1.value1::numeric, t1.value3::numeric) 
		WHEN (t1.v1+t1.v2+t1.v3) = 2 AND t1.v2 = 1 AND t1.v3 = 1 THEN LEAST(t1.value2::numeric, t1.value3::numeric) 
	END AS range_low,
	CASE
		WHEN (t1.v1+t1.v2+t1.v3) = 3 THEN GREATEST(t1.value1::numeric, t1.value2::numeric) 
		WHEN (t1.v1+t1.v2+t1.v3) = 2 AND t1.v1 = 1 AND t1.v2 = 1 THEN GREATEST(t1.value1::numeric, t1.value2::numeric) 
		WHEN (t1.v1+t1.v2+t1.v3) = 2 AND t1.v1 = 1 AND t1.v3 = 1 THEN GREATEST(t1.value1::numeric, t1.value3::numeric) 
		WHEN (t1.v1+t1.v2+t1.v3) = 2 AND t1.v2 = 1 AND t1.v3 = 1 THEN GREATEST(t1.value2::numeric, t1.value3::numeric)  
	END AS range_high,
	t7._target_concept_id as operator_concept_id,
	t6.source_code as unit_source_value,
	t6.source_concept_id as unit_source_concept_id,
	'gp_clinical' as stem_source_table,
	t1.id as stem_source_id
from cte2 as t1
join {SOURCE_SCHEMA}.lookup626 as lkup on lkup.code = t1.data_provider
join _read on t1.read_2 = _read._read_2
join {TARGET_SCHEMA}.observation_period as t2 on t1.eid = t2.person_id
join cte1 as t3 on t3.person_id = t1.eid and t3.visit_detail_start_date = t1.event_dt and t3.visit_detail_source_value = concat(lkup.description, '-Clinical')
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.read_2 = t4.source_code and t4.source_vocabulary_id = 'UKB_GP_CLINICAL_READ_STCM'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t5 on concat(t1.read_2, '00') = t5.source_code and t5.source_vocabulary_id = 'Read'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t6 on t1.value3 = t6.source_code and t6.source_vocabulary_id = 'UKB_GP_CLINICAL_UNIT_STCM'
left join _operator as t7 on t7._operator = t1.value1 or t7._operator = t1.value2 or t7._operator = t1.value3
where t1.event_dt >= t2.observation_period_start_date and t1.event_dt <= t2.observation_period_end_date;

-- others
With cte0 AS(
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select stem_source_id::numeric as id
	from {CHUNK_SCHEMA}.stem_source_{CHUNK_ID}
	where stem_source_table = 'gp_clinical'
), cte2 as(
	select t3.*
	from {SOURCE_SCHEMA}.temp_visit_detail as t1 
	join cte0 as t2 on t1.person_id = t2.person_id
	join {TARGET_SCHEMA}.visit_detail as t3 on t1.visit_detail_id = t3.visit_detail_id
	where t1.source_table = 'Clinical'
), _operator AS(
	select * FROM (VALUES 
		('OPR001', 4171756),
		('OPR002', 4171754),
		('OPR003', 4172703),
		('OPR004', 4172704),
		('OPR005', 4171755),
		('OPR006', 0),
		('<', 4171756),
		('<=', 4171754),
		('=', 4172703),
		('>', 4172704),
		('>=', 4171755),
		('~', 0)
	)AS t (_operator, _target_concept_id)		
), _gp_clinical as(
select distinct
		t1.id,
		t1.eid,
		t1.data_provider,
		t1.event_dt,
		t1.read_2,
		t7._target_concept_id as operator_concept_id, --operator for measurement
		t7._operator as qualifier_source_value,
		t7._target_concept_id as qualifier_concept_id, ----qualifier for observation
		CASE WHEN t1.value1 ~ '^[0-9]{8}$' OR t1.value1 = 'OPR003' THEN NULL ELSE t1.value1 END as value1,
		CASE WHEN t1.value2 ~ '^[0-9]{8}$' OR t1.value2 = 'OPR003' THEN NULL ELSE t1.value2 END as value2,
		CASE WHEN t1.value3 ~ '^[0-9]{8}$' OR t1.value3 = 'OPR003' THEN NULL ELSE t1.value3 END as value3,	
		case when COALESCE((regexp_match(t1.value1, '^\d+[.]\d+|^\d+'))[1] = t1.value1, false) AND t1.value1 !~ '^[0-9]{8}$' AND t1.value1 <> 'OPR003'  then 1 else 0 end as v1,
		case when COALESCE((regexp_match(t1.value2, '^\d+[.]\d+|^\d+'))[1] = t1.value2, false) AND t1.value2 !~ '^[0-9]{8}$' AND t1.value2 <> 'OPR003' then 1 else 0 end as v2,		
		case when COALESCE((regexp_match(t1.value3, '^\d+[.]\d+|^\d+'))[1] = t1.value3, false) AND t1.value3 !~ '^[0-9]{8}$' AND t1.value3 <> 'OPR003' then 1 else 0 end as v3
from {SOURCE_SCHEMA}.gp_clinical as t1
join cte0 on t1.eid = cte0.person_id
join {TARGET_SCHEMA}.observation_period as t2 on t1.eid = t2.person_id
left join _operator as t7 on t7._operator = t1.value1 or t7._operator = t1.value2 or t7._operator = t1.value3
left join cte1 as t3 on t1.id = t3.id
where t1.event_dt >= t2.observation_period_start_date and t1.event_dt <= t2.observation_period_end_date
and t1.read_2 is not null
and t3.id is null
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,  
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	value_as_string,
	operator_concept_id,
	qualifier_source_value,
	qualifier_concept_id,
	unit_concept_id,
	unit_source_value,
	unit_source_concept_id,
	stem_source_table,
	stem_source_id
)
select distinct
	t1.eid, 
	t3.visit_occurrence_id,
	t3.visit_detail_id,
	COALESCE(t4.source_code, t5.source_code, t1.read_2) as source_value, 
	COALESCE(t4.source_concept_id, t5.source_concept_id, 0) as source_concept_id,
	32817 as type_concept_id,
	t1.event_dt,
	t1.event_dt,
	'00:00:00'::time start_time,
	CASE 
		WHEN t1.read_2 = '22A..' THEN t1.value1 ::numeric
		WHEN (t1.v1+t1.v2+t1.v3) = 1 AND t1.v1 = 1 THEN t1.value1::numeric
		WHEN (t1.v1+t1.v2+t1.v3) = 1 AND t1.v2 = 1 THEN t1.value2::numeric
		WHEN (t1.v1+t1.v2+t1.v3) = 1 AND t1.v3 = 1 THEN t1.value3::numeric
	END as value_as_number,
	CASE 
		WHEN (t1.v1+t1.v2+t1.v3) = 1 AND t1.v1 = 1 THEN COALESCE(t1.value2, CASE WHEN t6.source_code is not NULL THEN NULL ELSE t1.value3 END)
		WHEN (t1.v1+t1.v2+t1.v3) = 1 AND t1.v2 = 1 THEN COALESCE(t1.value1, CASE WHEN t6.source_code is not NULL THEN NULL ELSE t1.value3 END)
		WHEN (t1.v1+t1.v2+t1.v3) = 1 AND t1.v3 = 1 THEN COALESCE(t1.value1, t1.value2)
		WHEN (t1.v1+t1.v2+t1.v3) = 2 AND t1.v1=0 THEN t1.value1
		WHEN (t1.v1+t1.v2+t1.v3) = 2 AND t1.v2=0 THEN t1.value2
		WHEN (t1.v1+t1.v2+t1.v3) = 2 AND t1.v3=0 THEN t1.value3
		WHEN (t1.v1+t1.v2+t1.v3) = 0 THEN COALESCE(t1.value1, t1.value2, t1.value3)
	END as value_as_string,
	t1.operator_concept_id, --operator for measurement
	t1.qualifier_source_value,
	t1.qualifier_concept_id, ----qualifier for observation
	t6.target_concept_id as unit_concept_id,
	CASE 
		WHEN t1.read_2 = '22A..' THEN 'kg'
		WHEN t1.read_2 = '229..' and (t1.v1+t1.v2+t1.v3) = 1 AND t1.v1 = 1 AND t1.value1::numeric < 10 THEN 'meters'
		WHEN t1.read_2 = '229..' and (t1.v1+t1.v2+t1.v3) = 1 AND t1.v2 = 1 AND t1.value2::numeric < 10 THEN 'meters'
		WHEN t1.read_2 = '229..' and (t1.v1+t1.v2+t1.v3) = 1 AND t1.v3 = 1 AND t1.value3::numeric < 10 THEN 'meters'
		WHEN t1.read_2 = '229..' and (t1.v1+t1.v2+t1.v3) = 1 AND t1.v1 = 1 AND t1.value1::numeric > 10 THEN 'cm' 
		WHEN t1.read_2 = '229..' and (t1.v1+t1.v2+t1.v3) = 1 AND t1.v2 = 1 AND t1.value2::numeric > 10 THEN 'cm' 
		WHEN t1.read_2 = '229..' and (t1.v1+t1.v2+t1.v3) = 1 AND t1.v3 = 1 AND t1.value3::numeric > 10 THEN 'cm' 
		ELSE t6.source_code 
	END as unit_source_value,
	CASE 
		WHEN t1.read_2 in ('22A..''229..') THEN 0
		ELSE t6.source_concept_id
	END as unit_source_concept_id,
	'gp_clinical' as stem_source_table,
	t1.id as stem_source_id
from _gp_clinical as t1
join {SOURCE_SCHEMA}.lookup626 as lkup on lkup.code = t1.data_provider
join cte2 as t3 on t3.person_id = t1.eid and t3.visit_detail_start_date = t1.event_dt and t3.visit_detail_source_value = concat(lkup.description, '-Clinical')
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.read_2 = t4.source_code and t4.source_vocabulary_id = 'UKB_GP_CLINICAL_READ_STCM'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t5 on concat(t1.read_2, '00') = t5.source_code and t5.source_vocabulary_id = 'Read'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t6 on t1.value3 = t6.source_code and t6.source_vocabulary_id = 'UKB_GP_CLINICAL_UNIT_STCM';


create index idx_stem_source_{CHUNK_ID}_1 on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (source_concept_id);
create index idx_stem_source_{CHUNK_ID}_2 on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (source_value);
create index idx_stem_source_{CHUNK_ID}_3 on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (value_as_string);


-----------------------------------------
-- UPDATE CHUNK
-----------------------------------------
update {CHUNK_SCHEMA}.chunk 
set stem_source_tbl = concat('stem_source_',{CHUNK_ID}::varchar)
where chunk_id = {CHUNK_ID};