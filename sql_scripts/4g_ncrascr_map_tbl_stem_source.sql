CREATE TABLE {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (LIKE {TARGET_SCHEMA}.STEM_SOURCE);

-------------------------------------------
--insert into stem_source table from tumour
-------------------------------------------
WITH cte0 as (
		select person_id
		from {CHUNK_SCHEMA}.chunk_person
		where chunk_id = {CHUNK_ID}
),
cte1 as (
		select t2.e_patid as person_id, 
		t2.e_cr_id, 
		t2.diagnosisdatebest as start_date, 
		t2.morph_icd10_o2 || '/' || t2.behaviour_icd10_o2 || '-' || site_icd10_o2 || '.9' as source_code
		,t2.basisofdiagnosis, t2.dco
		from cte0 as t1
		inner join {SOURCE_SCHEMA}.tumour as t2 on t1.person_id = t2.e_patid
),
cte2 as (
		select t1.person_id, 
		t1.e_cr_id, 
		t1.start_date, 
		t1.source_code as source_value,
		COALESCE(t2.source_concept_id, 0) as source_concept_id,
		CASE 
			WHEN t1.basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(t1.dco) = 'Y' THEN 0
			ELSE t1.basisofdiagnosis 
		END as type_source_value
		from cte1 as t1
		left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t1.source_code = t2.source_code 
		and t2.source_vocabulary_id = 'ICDO3'
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (domain_id, person_id, visit_occurrence_id, visit_detail_id, provider_id, concept_id, source_value,
					 source_concept_id, type_concept_id, start_date, end_date, start_time, days_supply, dose_unit_concept_id,
					 dose_unit_source_value, effective_drug_dose, lot_number, modifier_source_value, 
					 operator_concept_id, qualifier_concept_id, qualifier_source_value, quantity, 
					 range_high, range_low, refills, route_concept_id, route_source_value, sig, stop_reason, unique_device_id, unit_concept_id,
					 unit_source_value, value_as_concept_id, value_as_number, value_as_string,
					 value_source_value, anatomic_site_concept_id, disease_status_concept_id, specimen_source_id, anatomic_site_source_value, disease_status_source_value, 
					 modifier_concept_id, stem_source_table, stem_source_id)
select NULL as domain_id,
	t1.person_id, 
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	NULL as provider_id,
	NULL as concept_id,
	t1.source_value,
	t1.source_concept_id,
	COALESCE(t3.target_concept_id, 32879) as type_concept_id,
	t1.start_date,
	t1.start_date as end_date,
	'00:00:00'::time start_time,
	NULL as days_supply,
	0 as dose_unit_concept_id,
	NULL as dose_unit_source_value, 
	NULL as effective_drug_dose, 
	NULL as lot_number, 
	NULL as modifier_source_value,
	0 as operator_concept_id,
	0 as qualifier_concept_id,
	NULL as qualifier_source_value, 
	NULL as quantity, 
	NULL::double precision as range_high,
	NULL::double precision as range_low,
	NULL as refills,
	0 as route_concept_id,
	NULL as route_source_value,
	0 as unit_concept_id,
	NULL as sig, 
	NULL as stop_reason, 
	NULL as unique_device_id,
	NULL as unit_source_value,
	0 as value_as_concept_id,
	NULL::int as value_as_number,
	NULL as value_as_string,
	NULL::varchar value_source_value,
	0 as anatomic_site_concept_id,
	0 as disease_status_concept_id,
	NULL as specimen_source_id,
	NULL as anatomic_site_source_value, 
	NULL as disease_status_source_value, 
	0 as modifier_concept_id,
	'Tumour' stem_source_table,
	t1.e_cr_id as stem_source_id
from cte2 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.e_cr_id = t2.visit_detail_source_id
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.type_source_value = t3.source_code::numeric and t3.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t2.source_table = 'Tumour';


-------------------------------------------
--insert into stem_source from treatment
-------------------------------------------
WITH cte1 as (
		select person_id
		from {CHUNK_SCHEMA}.chunk_person
		where chunk_id = {CHUNK_ID}
	),
	cte2a as (
-- when there is an OPCS4 code
		select t1.person_id, 
		t2.treatment_id, 
		t2.eventdate as start_date, 
		left(t2.opcs4_code, 3) || '.' || right(t2.opcs4_code, 1) as source_code
		from cte1 as t1
		inner join {SOURCE_SCHEMA}.treatment as t2 on t1.person_id = t2.e_patid
		where t2.eventdate is not NULL
		AND t2.opcs4_code is not null
	),
	cte3a as (
		select t1.person_id,
		t1.treatment_id,
		t1.start_date,
		t1.source_code as source_value,
		COALESCE(t2.source_concept_id, 0) as source_concept_id
		from cte2a as t1
		left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_code = t1.source_code
		and t2.source_vocabulary_id = 'OPCS4'
	),
-- when there is NOT an OPCS4 code
	cte2b_1 as (
		select t1.person_id, 
		t2.treatment_id, 
		t2.eventdate as start_date, 
		TRIM(SPLIT_PART(chemo_all_drug,',',1)) as ing1,
		TRIM(SPLIT_PART(chemo_all_drug,',',2)) as ing2,
		TRIM(SPLIT_PART(chemo_all_drug,',',3)) as ing3
		from cte1 as t1
		inner join {SOURCE_SCHEMA}.treatment as t2 on t1.person_id = t2.e_patid
		where t2.eventdate is not NULL
		AND t2.opcs4_code is null
		AND t2.chemo_all_drug is not null
		AND t2.chemo_all_drug not in ('UNKNOWN', 'NOT YET CLASSIFIED', 'NOT CHEMO', 'HORMONE THERAPY NOS', 'IMMUNOTHERAPY NOS', 'CHEMOTHERAPY NOS')
	),
	cte2b_2 as (
		select person_id, treatment_id, start_date, ing1 as source_code from cte2b_1 
		WHERE ing1 <> ''
		UNION ALL
		select person_id, treatment_id, start_date, ing2 as source_code from cte2b_1 
		WHERE ing2 <> ''
		UNION ALL
		select person_id, treatment_id, start_date, ing3 as source_code from cte2b_1 
		WHERE ing3 <> ''
	),
	cte3b as (
		select t1.person_id,
		t1.treatment_id,
		t1.start_date,
		t1.source_code as source_value,
		COALESCE(t2.source_concept_id, 0) as source_concept_id
		from cte2b_2 as t1
		left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on upper(t1.source_code) = upper(t2.source_code_description) 
		and t2.source_vocabulary_id in ('RxNorm', 'RxNorm Extension') and t2.source_concept_class_id = 'Ingredient'
		left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t3.source_code = t1.source_code
		and t2.source_concept_id is null and t3.source_vocabulary_id = 'NCRAS_STCM'
	),
	cte2b_3 as (
		select t1.person_id, 
		t2.treatment_id, 
		t2.eventdate as start_date, 
		CASE	WHEN radiodesc is null and chemo_all_drug is null THEN eventdesc
				WHEN radiodesc is not null THEN
					CASE WHEN radiodesc in ('RADIOACTIVE ISOTOPES', 'BRACHYTHERAPY', 'INTRACAVITARY OR INTERSTITIAL', 'EXTERNAL BEAM')
						THEN radiodesc
						ELSE eventdesc
					END
				WHEN chemo_all_drug is not null THEN
					CASE WHEN chemo_all_drug in ('UNKNOWN', 'NOT YET CLASSIFIED', 'NOT CHEMO') THEN eventdesc
						WHEN chemo_all_drug in ('HORMONE THERAPY NOS', 'IMMUNOTHERAPY NOS', 'CHEMOTHERAPY NOS') THEN chemo_all_drug
					END
		END as source_code
		from cte1 as t1
		inner join {SOURCE_SCHEMA}.treatment as t2 on t1.person_id = t2.e_patid
		where t2.eventdate is not NULL
		AND t2.opcs4_code is null
		AND (t2.chemo_all_drug is null or t2.chemo_all_drug in ('UNKNOWN', 'NOT YET CLASSIFIED', 'NOT CHEMO', 'HORMONE THERAPY NOS', 'IMMUNOTHERAPY NOS', 'CHEMOTHERAPY NOS'))
	),
	cte3c as (
		select t1.person_id,
		t1.treatment_id,
		t1.start_date,
		t1.source_code as source_value,
		COALESCE(t2.source_concept_id, 0) as source_concept_id
		from cte2b_3 as t1
		left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_code = t1.source_code
		and t2.source_vocabulary_id = 'NCRAS_STCM'
	),
	cte3 as (
		select * from cte3a
		UNION ALL
		select * from cte3b
		UNION ALL
		select * from cte3c
	)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (domain_id, person_id, visit_occurrence_id, visit_detail_id, provider_id, concept_id, source_value,
										 source_concept_id, type_concept_id, start_date, end_date, start_time, days_supply, dose_unit_concept_id,
										 dose_unit_source_value, effective_drug_dose, lot_number, modifier_source_value, operator_concept_id, qualifier_concept_id,
										 qualifier_source_value, quantity, range_high, range_low, refills, route_concept_id, route_source_value,
										 sig, stop_reason, unique_device_id, unit_concept_id, unit_source_value, value_as_concept_id, value_as_number,
										 value_as_string, value_source_value, anatomic_site_concept_id, disease_status_concept_id, specimen_source_id,
										 anatomic_site_source_value, disease_status_source_value, modifier_concept_id, stem_source_table, stem_source_id)
select NULL as domain_id,
		t1.person_id,
		t2.visit_occurrence_id,
		t2.visit_detail_id,
		NULL as provider_id,
		NULL as concept_id,
		t1.source_value,
		t1.source_concept_id,
		32879 as type_concept_id,	--Registry
		t1.start_date,
		t1.start_date as end_date,
		'00:00:00'::time,
		NULL::int,
		0,
		NULL,
		NULL,
		NULL,
		NULL,
		0,
		0,
		NULL,
		NULL::double precision,
		NULL::double precision,
		NULL::double precision,
		NULL::int,
		0,
		NULL,
		NULL,
		NULL,
		NULL,
		0,
		NULL,
		0,
		NULL::double precision,
		NULL,
		NULL,
		0,
		0,
		NULL,
		NULL,
		NULL,
		0,
		'Treatment',
		t1.treatment_id as stem_source_id
from cte3 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail t2 on t1.treatment_id = t2.visit_detail_source_id
where t2.source_table = 'Treatment';

------------------------------------------------------------------------
-- Cancer Diagnostic Modifiers 'Tumour-[modifier]' as stem_source_table
------------------------------------------------------------------------
WITH cte0 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select 	t1.*
	from {SOURCE_SCHEMA}.tumour as t1
	join cte0 on cte0.person_id = t1.e_patid
	join {TARGET_SCHEMA}.observation_period as t2 on t1.e_patid = t2.person_id
	WHERE t1.diagnosisdatebest >= t2.observation_period_start_date and t1.diagnosisdatebest <= t2.observation_period_end_date
), cte2 as(
	select
		e_patid,	
		CASE 
			WHEN basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
			ELSE basisofdiagnosis 
		END as type_source_value,
		diagnosisdatebest as start_date,
		'tumoursize' as source_value,
		tumoursize as value_as_number,
		'mm' as unit_source_value,  		
		e_cr_id
	from cte1
	where tumoursize is not null

	union

	select 
		e_patid,
		CASE 
			WHEN basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
			ELSE basisofdiagnosis 
		END as type_source_value,
		diagnosisdatebest as start_date,
		'nodesexcised' as source_value,
		nodesexcised as value_as_number,
		null as unit_source_value,
		e_cr_id
	from cte1
	where nodesexcised is not null

	union

	select 
		e_patid,
		CASE 
			WHEN basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
			ELSE basisofdiagnosis 
		END as type_source_value,
		diagnosisdatebest as start_date,
		'nodesinvolved' as source_value,
		nodesinvolved as value_as_number,
		null as unit_source_value,
		e_cr_id
	from cte1
	where nodesinvolved is not null

	union

	select 
		e_patid,
		CASE 
			WHEN basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
			ELSE basisofdiagnosis 
		END as type_source_value,
		diagnosisdatebest as start_date,
		'tumourcount' as source_value,
		tumourcount as value_as_number,
		null as unit_source_value,
		e_cr_id
	from cte1
	where tumourcount is not null

	union

	select 
		e_patid,
		CASE 
			WHEN basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
			ELSE basisofdiagnosis 
		END as type_source_value,
		diagnosisdatebest as start_date,
		'bigtumourcount' as source_value,
		bigtumourcount as value_as_number,
		null as unit_source_value,
		e_cr_id
	from cte1
	where bigtumourcount is not null

	union

	select 
		e_patid,
		CASE 
			WHEN basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
			ELSE basisofdiagnosis 
		END as type_source_value,
		diagnosisdatebest as start_date,
		'chrl_tot_27_03' as source_value,
		chrl_tot_27_03 as value_as_number,
		null as unit_source_value,
		e_cr_id
	from cte1
	where chrl_tot_27_03 is not null

	union

	select 
		e_patid,
		CASE 
			WHEN basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
			ELSE basisofdiagnosis 
		END as type_source_value,
		diagnosisdatebest as start_date,
		'chrl_tot_78_06' as source_value,
		chrl_tot_78_06 as value_as_number,
		null as unit_source_value,
		e_cr_id
	from cte1
	where chrl_tot_78_06 is not null

	union

	select 
		e_patid,
		CASE 
			WHEN basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
			ELSE basisofdiagnosis 
		END as type_source_value,
		diagnosisdatebest as start_date,
		'gleason_combined' as source_value,
		gleason_combined as value_as_number,
		null as unit_source_value,
		e_cr_id
	from cte1
	where gleason_combined is not null
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
	value_source_value,
	stem_source_table,
	stem_source_id
)
select distinct								
	t1.e_patid as person_id,
	tt.visit_occurrence_id,
	tt.visit_detail_id,
	t1.source_value,
	COALESCE(t2.source_concept_id, 0) as source_concept_id,
	COALESCE(t3.target_concept_id, 32879) as type_concept_id,
	t1.start_date as start_date,
	t1.start_date as end_date,
	'00:00:00'::time start_time,
	t1.value_as_number,
	t1.unit_source_value,
	t1.source_value as value_source_value,
	'Tumour-Modifier' as stem_source_table,
	t1.e_cr_id as stem_source_id
from cte2 as t1
join {SOURCE_SCHEMA}.temp_visit_detail as tt on t1.e_cr_id = tt.visit_detail_source_id and tt.source_table = 'Tumour'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_code = t1.source_value and t2.source_vocabulary_id = 'NCRAS_TUMOUR_MODIFIER_STCM' 
and t2.target_domain_id = 'Measurement'  -- for Athena changes target domain during STCM update
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.type_source_value = t3.source_code::numeric and t3.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM';


-- GRADE 
WITH cte0 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select 
		t1.e_patid,
		t1.grade,
		CASE 
			WHEN basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
			ELSE basisofdiagnosis 
		END as type_source_value,
		t1.diagnosisdatebest,
		t1.e_cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	join cte0 on cte0.person_id = t1.e_patid
	join {TARGET_SCHEMA}.observation_period as t2 on t1.e_patid = t2.person_id
	where t1.grade is not null 
	and t1.diagnosisdatebest >= t2.observation_period_start_date and t1.diagnosisdatebest <= t2.observation_period_end_date
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
	value_source_value,
	stem_source_table,
	stem_source_id
)
select distinct
	t1.e_patid as person_id,
	tt.visit_occurrence_id,
	tt.visit_detail_id,
	t1.grade as source_value,
	COALESCE(t2.source_concept_id, 0) as source_concept_id,
	COALESCE(t3.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	'grade' as value_source_value,
	'Tumour-Grade' stem_source_table,
	t1.e_cr_id as stem_source_id
from cte1 as t1
join {SOURCE_SCHEMA}.temp_visit_detail as tt on t1.e_cr_id = tt.visit_detail_source_id and tt.source_table = 'Tumour'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_code = t1.grade and t2.source_vocabulary_id = 'NCRAS_TUMOUR_GRADE_STCM' and t2.target_domain_id = 'Measurement'  -- for Athena changes target domain during STCM update
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.type_source_value = t3.source_code::numeric and t3.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM';

-- stage_best, stage_img, stage_path
WITH cte0 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select 
		t1.e_cr_id,
		t1.e_patid,
		CASE 
			WHEN t1.basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
			ELSE t1.basisofdiagnosis 
		END as type_source_value,
		t1.diagnosisdatebest,
		CASE
			WHEN t1.stage_best_system in ('6th', 'UICC 6') THEN '6TH_'
			WHEN t1.stage_best_system in ('7th', 'UICC 7', 'AJCC 7') THEN '7TH_'
			WHEN t1.stage_best_system in ('8th', 'UICC 8', 'UICC 8') THEN  '8TH_'
			ELSE ''
		END as stage_system,
		t1.stage_best as source_value,
		'stage_best' as value_source_value
	from {SOURCE_SCHEMA}.tumour as t1
	join cte0 as t2 on t1.e_patid = t2.person_id
	where t1.stage_best is not null 
	
	UNION
	
	select 
		t1.e_cr_id,
		t1.e_patid,
		CASE 
			WHEN t1.basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
			ELSE t1.basisofdiagnosis 
		END as type_source_value,
		t1.diagnosisdatebest,
		CASE
			WHEN t1.stage_img_system in (6, 21) THEN '6TH_'
			WHEN t1.stage_img_system in (7, 22, 23) THEN '7TH_'
			WHEN t1.stage_img_system in (8, 25, 26) THEN  '8TH_'
			ELSE ''
		END as stage_system,
		t1.stage_img as source_value,
		'stage_img' as value_source_value
	from {SOURCE_SCHEMA}.tumour as t1
	join cte0 as t2 on t1.e_patid = t2.person_id
	where t1.stage_img is not null 

	UNION
	
	select 
		t1.e_cr_id,
		t1.e_patid,
		CASE 
			WHEN t1.basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
			ELSE t1.basisofdiagnosis 
		END as type_source_value,
		t1.diagnosisdatebest,
		CASE
			WHEN t1.stage_path_system in (6, 21) THEN '6TH_'
			WHEN t1.stage_path_system in (7, 22, 23) THEN '7TH_'
			WHEN t1.stage_path_system in (8, 25, 26) THEN  '8TH_'
			ELSE ''
		END as stage_system,
		t1.stage_path as source_value,
		'stage_path' as value_source_value
	from {SOURCE_SCHEMA}.tumour as t1
	join cte0 as t2 on t1.e_patid = t2.person_id
	where t1.stage_path is not null 
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
	value_source_value,
	stem_source_table,
	stem_source_id
)
select distinct
	t1.e_patid as person_id,
	tt.visit_occurrence_id,
	tt.visit_detail_id,
	COALESCE(t2.source_code, t3.source_code, t1.source_value) as source_value,
	COALESCE(t2.source_concept_id, t3.source_concept_id, 0) as source_concept_id,
	COALESCE(t4.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	t1.value_source_value,
	'Tumour-Stage' as stem_source_table,
	t1.e_cr_id as stem_source_id
from cte1 as t1
join {TARGET_SCHEMA}.observation_period as t5 on t1.e_patid = t5.person_id
join {SOURCE_SCHEMA}.temp_visit_detail as tt on t1.e_cr_id = tt.visit_detail_source_id and tt.source_table = 'Tumour'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_vocabulary_id = 'Cancer Modifier' and UPPER(t2.source_code) = UPPER(t1.stage_system || 'AJCC/UICC-STAGE-'|| t1.source_value) and t2.target_domain_id = 'Measurement' -- for Athena changes target domain during STCM update
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t3.source_vocabulary_id = 'Cancer Modifier' and UPPER(t3.source_code) = UPPER(t1.stage_system || 'AJCC/UICC-STAGE-'|| LEFT(t1.source_value, 1)) and t3.target_domain_id = 'Measurement' 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.type_source_value = t4.source_code::numeric and t4.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
where t1.diagnosisdatebest >= t5.observation_period_start_date and t1.diagnosisdatebest <= t5.observation_period_end_date;

-- t_best, n_best, m_best
WITH cte0 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select 
		t1.e_cr_id,
		t1.e_patid,
		CASE 
			WHEN t1.basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
			ELSE t1.basisofdiagnosis 
		END as type_source_value,
		t1.diagnosisdatebest,
		CASE
			WHEN t1.stage_best_system in ('6th', 'UICC 6') THEN '6TH_'
			WHEN t1.stage_best_system in ('7th', 'UICC 7', 'AJCC 7') THEN '7TH_'
			WHEN t1.stage_best_system in ('8th', 'UICC 8', 'UICC 8') THEN  '8TH_'
			ELSE ''
		END as stage_system,
		CASE
			WHEN LEFT(t1.t_best, 1) in ('T', 't') THEN t1.t_best
			ELSE 'T' || t1.t_best
		END as tnm_code,
		t1.t_best as source_value,
		't_best' as modifier
	from {SOURCE_SCHEMA}.tumour as t1
	join cte0 as t2 on t1.e_patid = t2.person_id
	where t1.t_best is not null
	
	UNION
	
	select 
		t1.e_cr_id,
		t1.e_patid,
		CASE 
			WHEN t1.basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
			ELSE t1.basisofdiagnosis 
		END as type_source_value,
		t1.diagnosisdatebest,
		CASE
			WHEN t1.stage_best_system in ('6th', 'UICC 6') THEN '6TH_'
			WHEN t1.stage_best_system in ('7th', 'UICC 7', 'AJCC 7') THEN '7TH_'
			WHEN t1.stage_best_system in ('8th', 'UICC 8', 'UICC 8') THEN  '8TH_'
			ELSE ''
		END as stage_system,
		CASE
			WHEN LEFT(t1.n_best, 1) in ('N', 'n') THEN t1.n_best
			ELSE 'N' || t1.n_best
		END as tnm_code,
		t1.n_best as source_value,
		'n_best' as modifier
	from {SOURCE_SCHEMA}.tumour as t1
	join cte0 as t2 on t1.e_patid = t2.person_id
	where t1.n_best is not null
	
	UNION
	
	select 
		t1.e_cr_id,
		t1.e_patid,
		CASE 
			WHEN t1.basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
			ELSE t1.basisofdiagnosis 
		END as type_source_value,
		t1.diagnosisdatebest,
		CASE
			WHEN t1.stage_best_system in ('6th', 'UICC 6') THEN '6TH_'
			WHEN t1.stage_best_system in ('7th', 'UICC 7', 'AJCC 7') THEN '7TH_'
			WHEN t1.stage_best_system in ('8th', 'UICC 8', 'UICC 8') THEN  '8TH_'
			ELSE ''
		END as stage_system,
		CASE
			WHEN LEFT(t1.m_best, 1) in ('M', 'm') THEN t1.m_best
			ELSE 'M' || t1.m_best
		END as tnm_code,
		t1.m_best as source_value,
		'm_best' as modifier
	from {SOURCE_SCHEMA}.tumour as t1
	join cte0 as t2 on t1.e_patid = t2.person_id 
	where t1.m_best is not null 
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
	value_source_value,
	stem_source_table,
	stem_source_id
)
select 
	t1.e_patid as person_id,
	tt.visit_occurrence_id,
	tt.visit_detail_id,
	COALESCE(t2.source_code, t1.source_value) as source_value,
	COALESCE(t2.source_concept_id, 0) as source_concept_id,
	COALESCE(t4.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	modifier as value_source_value,
	'Tumour' || '-' || modifier as  stem_source_table,
	t1.e_cr_id as stem_source_id
from cte1 as t1
join {TARGET_SCHEMA}.observation_period as t3 on t1.e_patid = t3.person_id
join {SOURCE_SCHEMA}.temp_visit_detail as tt on t1.e_cr_id = tt.visit_detail_source_id and tt.source_table = 'Tumour'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on UPPER(t2.source_code) = UPPER(t1.stage_system || 'AJCC/UICC-'|| t1.tnm_code) 
and t2.source_vocabulary_id = 'Cancer Modifier' and t2.target_domain_id = 'Measurement' -- for Athena changes target domain during STCM update
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.type_source_value = t4.source_code::numeric and t4.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
where t1.diagnosisdatebest >= t3.observation_period_start_date and t1.diagnosisdatebest <= t3.observation_period_end_date;


-- t_img, n_img, m_img
WITH cte0 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select 
		t1.e_cr_id,
		t1.e_patid,
		CASE 
			WHEN t1.basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
			ELSE t1.basisofdiagnosis 
		END as type_source_value,
		t1.diagnosisdatebest,
		CASE
			WHEN t1.stage_img_system in (6, 21) THEN '6TH_'
			WHEN t1.stage_img_system in (7, 22, 23) THEN '7TH_'
			WHEN t1.stage_img_system in (8, 25, 26) THEN  '8TH_'
			ELSE ''
		END as stage_system,
		CASE
			WHEN LEFT(t1.t_img, 1) in ('T', 't') THEN t1.t_img
			ELSE 'T' || t1.t_img
		END as tnm_code,
		t1.t_img as source_value,
		't_img' as modifier
	from {SOURCE_SCHEMA}.tumour as t1
	join cte0 as t2 on t1.e_patid = t2.person_id
	where t1.t_img is not null
	
	UNION
	
	select 
		t1.e_cr_id,
		t1.e_patid,
		CASE 
			WHEN t1.basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
			ELSE t1.basisofdiagnosis 
		END as type_source_value,
		t1.diagnosisdatebest,
		CASE
			WHEN t1.stage_img_system in (6, 21) THEN '6TH_'
			WHEN t1.stage_img_system in (7, 22, 23) THEN '7TH_'
			WHEN t1.stage_img_system in (8, 25, 26) THEN  '8TH_'
			ELSE ''
		END as stage_system,
		CASE
			WHEN LEFT(t1.n_img, 1) in ('N', 'n') THEN t1.n_img
			ELSE 'N' || t1.n_img
		END as tnm_code,
		t1.n_img as source_value,	
		'n_img' as modifier
	from {SOURCE_SCHEMA}.tumour as t1
	join cte0 as t2 on t1.e_patid = t2.person_id
	where t1.n_img is not null
	
	UNION
	
	select 
		t1.e_cr_id,
		t1.e_patid,
		CASE 
			WHEN t1.basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
			ELSE t1.basisofdiagnosis 
		END as type_source_value,
		t1.diagnosisdatebest,
		CASE
			WHEN t1.stage_img_system in (6, 21) THEN '6TH_'
			WHEN t1.stage_img_system in (7, 22, 23) THEN '7TH_'
			WHEN t1.stage_img_system in (8, 25, 26) THEN  '8TH_'
			ELSE ''
		END as stage_system,
		CASE
			WHEN LEFT(t1.m_img, 1) in ('M', 'm') THEN t1.m_img
			ELSE 'M' || t1.m_img
		END as tnm_code,
		t1.m_img as source_value,	
		'm_img' as modifier
	from {SOURCE_SCHEMA}.tumour as t1
	join cte0 as t2 on t1.e_patid = t2.person_id 
	where t1.m_img is not null 
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
	value_source_value,
	stem_source_table,
	stem_source_id
)
select 
	t1.e_patid as person_id,
	tt.visit_occurrence_id,
	tt.visit_detail_id,
	COALESCE(t2.source_code, t1.source_value) as source_value,
	COALESCE(t2.source_concept_id, 0) as source_concept_id,
	COALESCE(t4.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	modifier as value_source_value,
	'Tumour' || '-' || modifier as stem_source_table,
	t1.e_cr_id as stem_source_id
from cte1 as t1
join {TARGET_SCHEMA}.observation_period as t3 on t1.e_patid = t3.person_id
join {SOURCE_SCHEMA}.temp_visit_detail as tt on t1.e_cr_id = tt.visit_detail_source_id and tt.source_table = 'Tumour'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on UPPER(t2.source_code) = UPPER(t1.stage_system || 'AJCC/UICC-'|| t1.tnm_code) 
and t2.source_vocabulary_id = 'Cancer Modifier' and t2.target_domain_id = 'Measurement' -- for Athena changes target domain during STCM update
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.type_source_value = t4.source_code::numeric and t4.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
where t1.diagnosisdatebest >= t3.observation_period_start_date and t1.diagnosisdatebest <= t3.observation_period_end_date;


-- t_path, n_path, m_path
WITH cte0 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select 
		t1.e_cr_id,
		t1.e_patid,
		CASE 
			WHEN t1.basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
			ELSE t1.basisofdiagnosis 
		END as type_source_value,
		t1.diagnosisdatebest,
		CASE
			WHEN t1.stage_path_system in (6, 21) THEN '6TH_'
			WHEN t1.stage_path_system in (7, 22, 23) THEN '7TH_'
			WHEN t1.stage_path_system in (8, 25, 26) THEN  '8TH_'
			ELSE ''
		END as stage_system,
		CASE
			WHEN LEFT(t1.t_path, 1) in ('T', 't') THEN t1.t_path
			ELSE 'T' || t1.t_path
		END as tnm_code,
		t1.t_path as source_value,	
		't_path' as modifier
	from {SOURCE_SCHEMA}.tumour as t1
	join cte0 as t2 on t1.e_patid = t2.person_id
	where t1.t_path is not null
	
	UNION
	
	select 
		t1.e_cr_id,
		t1.e_patid,
		CASE 
			WHEN t1.basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
			ELSE t1.basisofdiagnosis 
		END as type_source_value,
		t1.diagnosisdatebest,
		CASE
			WHEN t1.stage_path_system in (6, 21) THEN '6TH_'
			WHEN t1.stage_path_system in (7, 22, 23) THEN '7TH_'
			WHEN t1.stage_path_system in (8, 25, 26) THEN  '8TH_'
			ELSE ''
		END as stage_system,
		CASE
			WHEN LEFT(t1.n_path, 1) in ('N', 'n') THEN t1.n_path
			ELSE 'N' || t1.n_path
		END as tnm_code,
		t1.n_path as source_value,
		'n_path' as modifier
	from {SOURCE_SCHEMA}.tumour as t1
	join cte0 as t2 on t1.e_patid = t2.person_id
	where t1.n_path is not null
	
	UNION
	
	select 
		t1.e_cr_id,
		t1.e_patid,
		CASE 
			WHEN t1.basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
			ELSE t1.basisofdiagnosis 
		END as type_source_value,
		t1.diagnosisdatebest,
		CASE
			WHEN t1.stage_path_system in (6, 21) THEN '6TH_'
			WHEN t1.stage_path_system in (7, 22, 23) THEN '7TH_'
			WHEN t1.stage_path_system in (8, 25, 26) THEN  '8TH_'
			ELSE ''
		END as stage_system,
		CASE
			WHEN LEFT(t1.m_path, 1) in ('M', 'm') THEN t1.m_path
			ELSE 'M' || t1.m_path
		END as tnm_code,
		t1.m_path as source_value,
		'm_path' as modifier
	from {SOURCE_SCHEMA}.tumour as t1
	join cte0 as t2 on t1.e_patid = t2.person_id 
	where t1.m_path is not null 
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
	value_source_value,
	stem_source_table,
	stem_source_id
)
select 
	t1.e_patid as person_id,
	tt.visit_occurrence_id,
	tt.visit_detail_id,
	COALESCE(t2.source_code, t1.source_value) as source_value,
	COALESCE(t2.source_concept_id, 0) as source_concept_id,
	COALESCE(t4.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	modifier as value_source_value,
	'Tumour' || '-' || modifier as stem_source_table,
	t1.e_cr_id as stem_source_id
from cte1 as t1
join {TARGET_SCHEMA}.observation_period as t3 on t1.e_patid = t3.person_id
join {SOURCE_SCHEMA}.temp_visit_detail as tt on t1.e_cr_id = tt.visit_detail_source_id and tt.source_table = 'Tumour'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on UPPER(t2.source_code) = UPPER(t1.stage_system || 'AJCC/UICC-'|| t1.tnm_code) 
and t2.source_vocabulary_id = 'Cancer Modifier' 
and t2.target_domain_id = 'Measurement' -- for Athena changes target domain during STCM update
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.type_source_value = t4.source_code::numeric and t4.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
where t1.diagnosisdatebest >= t3.observation_period_start_date and t1.diagnosisdatebest <= t3.observation_period_end_date;

-- gleason_primary 
WITH cte0 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select 
		t1.e_patid,
		CASE 
				WHEN t1.basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
				ELSE t1.basisofdiagnosis 
		END as type_source_value,
		t1.diagnosisdatebest,
		t1.gleason_primary,
		t1.e_cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	join cte0 as t2 on t1.e_patid = t2.person_id
	join {TARGET_SCHEMA}.observation_period as t3 on t1.e_patid = t3.person_id
	where t1.gleason_primary >= 1 and t1.gleason_primary <= 5
	and t1.diagnosisdatebest >= t3.observation_period_start_date and t1.diagnosisdatebest <= t3.observation_period_end_date
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
	value_source_value,
	stem_source_table,
	stem_source_id
)
select 
	t1.e_patid as person_id,
	tt.visit_occurrence_id,
	tt.visit_detail_id,
	t1.gleason_primary::text as source_value,
	COALESCE(t2.source_concept_id, 0) as source_concept_id,
	COALESCE(t3.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	t1.gleason_primary as value_as_number,
	'gleason_primary' as value_source_value,
	'Tumour-Gleason Primary' as stem_source_table,
	t1.e_cr_id as stem_source_id
from cte1 as t1
join {SOURCE_SCHEMA}.temp_visit_detail as tt on t1.e_cr_id = tt.visit_detail_source_id and tt.source_table = 'Tumour'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_code = t1.gleason_primary::text and t2.source_vocabulary_id = 'NCRAS_TUMOUR_GLEASON_PRI_STCM' 
and t2.target_domain_id = 'Measurement' -- for Athena changes target domain during STCM update
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.type_source_value = t3.source_code::numeric and t3.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM';

	
-- gleason_secondary 
WITH cte0 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select 
		t1.e_patid,
		CASE 
				WHEN t1.basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
				ELSE t1.basisofdiagnosis 
		END as type_source_value,
		t1.diagnosisdatebest,
		t1.gleason_secondary,
		t1.e_cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	join cte0 as t2 on t1.e_patid = t2.person_id
	join {TARGET_SCHEMA}.observation_period as t3 on t1.e_patid = t3.person_id
	where t1.gleason_secondary >= 1 and t1.gleason_secondary <= 5
	and t1.diagnosisdatebest >= t3.observation_period_start_date and t1.diagnosisdatebest <= t3.observation_period_end_date
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
	value_source_value,
	stem_source_table,
	stem_source_id
)
select 
	t1.e_patid as person_id,
	tt.visit_occurrence_id,
	tt.visit_detail_id,
	t1.gleason_secondary::text as source_value,
	COALESCE(t2.source_concept_id, 0) as source_concept_id,
	COALESCE(t3.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	t1.gleason_secondary as value_as_number,
	'gleason_secondary' as value_source_value,
	'Tumour-Gleason Secondary' as stem_source_table,
	t1.e_cr_id as stem_source_id
from cte1 as t1
join {SOURCE_SCHEMA}.temp_visit_detail as tt on t1.e_cr_id = tt.visit_detail_source_id and tt.source_table = 'Tumour'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_code = t1.gleason_secondary::text and t2.source_vocabulary_id = 'NCRAS_TUMOUR_GLEASON_SEC_STCM' 
and t2.target_domain_id = 'Measurement' -- for Athena changes target domain during STCM update
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.type_source_value = t3.source_code::numeric and t3.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM';


-- gleason_tertiary
WITH cte0 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select 
		t1.e_patid,
		CASE 
				WHEN t1.basisofdiagnosis NOT in (0,1,2,4,5,6,7) and upper(dco) = 'Y' THEN 0
				ELSE t1.basisofdiagnosis 
		END as type_source_value,
		t1.diagnosisdatebest,
		t1.gleason_tertiary,
		t1.e_cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	join cte0 as t2 on t1.e_patid = t2.person_id
	join {TARGET_SCHEMA}.observation_period as t3 on t1.e_patid = t3.person_id
	where t1.gleason_tertiary >= 1 and t1.gleason_tertiary <= 5  
	and t1.diagnosisdatebest >= t3.observation_period_start_date and t1.diagnosisdatebest <= t3.observation_period_end_date
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
	value_source_value,
	stem_source_table,
	stem_source_id
)
select 
	t1.e_patid as person_id,
	tt.visit_occurrence_id,
	tt.visit_detail_id,
	t1.gleason_tertiary::text as source_value,
	COALESCE(t2.source_concept_id, 0) as source_concept_id,
	COALESCE(t3.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	t1.gleason_tertiary as value_as_number,
	'gleason_tertiary' as value_source_value,
	'Tumour-Gleason Tertiary' as stem_source_table,
	t1.e_cr_id as stem_source_id
from cte1 as t1
join {SOURCE_SCHEMA}.temp_visit_detail as tt on t1.e_cr_id = tt.visit_detail_source_id and tt.source_table = 'Tumour'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_code = t1.gleason_tertiary::text and t2.source_vocabulary_id = 'NCRAS_TUMOUR_GLEASON_TER_STCM' 
and t2.target_domain_id = 'Measurement' -- for Athena changes target domain during STCM update
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.type_source_value = t3.source_code::numeric and t3.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM';


------------------------------------------------------------------
-- Treatment Modifiers 'Treatment-[modifier]' as stem_source_table
------------------------------------------------------------------
WITH cte0 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select 	t1.*
	from {SOURCE_SCHEMA}.treatment as t1
	join cte0 on cte0.person_id = t1.e_patid
	join {TARGET_SCHEMA}.observation_period as t2 on t1.e_patid = t2.person_id
	WHERE t1.eventdate >= t2.observation_period_start_date and t1.eventdate <= t2.observation_period_end_date
), cte2 as(
	select  
		e_patid,
		eventdate,
		'lesionsize' as source_value,
		lesionsize as value_as_number,
		'mm' as unit_source_value,
		treatment_id
	from cte1
	where lesionsize is not null

	UNION

	select 
		e_patid,
		eventdate,
		'number_of_tumours' as source_value,
		number_of_tumours as value_as_number,
		NULL as unit_source_value,
		treatment_id
	from cte1
	where number_of_tumours is not null
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
	value_source_value,
	stem_source_table,
	stem_source_id
)
select
	t1.e_patid as person_id,
	tt.visit_occurrence_id,
	tt.visit_detail_id,
	t1.source_value,
	COALESCE(t2.source_concept_id, 0) as source_concept_id,
	32879 as type_concept_id,
	t1.eventdate as start_date,
	t1.eventdate as end_date,
	'00:00:00'::time start_time,
	t1.value_as_number,
	t1.unit_source_value,
	t1.source_value as value_source_value,
	'Treatment-Modifier' as stem_source_table,
	t1.treatment_id as stem_source_id
from cte2 as t1
join {SOURCE_SCHEMA}.temp_visit_detail as tt on t1.treatment_id = tt.visit_detail_source_id and tt.source_table = 'Treatment'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_code = t1.source_value::text and t2.source_vocabulary_id = 'NCRAS_TREATMENT_MODIFIER_STCM' 
and t2.target_domain_id = 'Measurement'; -- for Athena changes target domain during STCM update

------------------------------
-- within_six_months_flag 
-- six_months_after_flag 
------------------------------
WITH cte0 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select 	t1.*
	from {SOURCE_SCHEMA}.treatment as t1
	join cte0 on cte0.person_id = t1.e_patid
	join {TARGET_SCHEMA}.observation_period as t2 on t1.e_patid = t2.person_id
	WHERE t1.eventdate >= t2.observation_period_start_date and t1.eventdate <= t2.observation_period_end_date
), cte2 as(
	select 
		e_patid,
		'within_six_months_flag' as source_value,
		eventdate,
		CASE 
			WHEN within_six_months_flag = 0 THEN 'N'
			WHEN within_six_months_flag = 1 THEN 'Y'
		END as value_as_string,
		'<=' as qualifier_source_value,
		4171754 as qualifier_concept_id,
		treatment_id
	from cte1
	
	UNION
	
	select
		e_patid,
		'six_months_after_flag' as source_value,
		eventdate,
		CASE 
			WHEN six_months_after_flag = 0 THEN 'N'
			WHEN six_months_after_flag = 1 THEN 'Y'
		END as value_as_string,
		'>' as qualifier_source_value,
		4172704 as qualifier_concept_id,
		treatment_id
	from cte1
	
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
	value_as_number,
	unit_source_value,
	qualifier_source_value,
	qualifier_concept_id,
	value_source_value,
	stem_source_table,
	stem_source_id
)
select  
	t1.e_patid as person_id,
	tt.visit_occurrence_id,
	tt.visit_detail_id,
	t1.source_value,
	COALESCE(t2.source_concept_id, 0) as source_concept_id,
	32879 as type_concept_id,
	t1.eventdate as start_date,
	t1.eventdate as end_date,
	'00:00:00'::time start_time,
	t1.value_as_string,
	6 as value_as_number,
	'month' as unit_source_value,
	t1.qualifier_source_value,
	t1.qualifier_concept_id,
	t1.source_value as value_source_value,
	'Treatment-Modifier' as stem_source_table,
	treatment_id as stem_source_id
from cte2 as t1
join {SOURCE_SCHEMA}.temp_visit_detail as tt on t1.treatment_id = tt.visit_detail_source_id and tt.source_table = 'Treatment'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_code = t1.source_value 
and t2.source_vocabulary_id = 'NCRAS_TREATMENT_MODIFIER_STCM';


create index idx_stem_source_{CHUNK_ID}_1 on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (source_concept_id);
create index idx_stem_source_{CHUNK_ID}_2 on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (source_value);
create index idx_stem_source_{CHUNK_ID}_3 on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (stem_source_table);


-----------------------------------------
-- UPDATE CHUNK
-----------------------------------------
update {CHUNK_SCHEMA}.chunk 
set stem_source_tbl = concat('stem_source_',{CHUNK_ID}::varchar)
where chunk_id = {CHUNK_ID};