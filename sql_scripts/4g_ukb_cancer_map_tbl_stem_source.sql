CREATE TABLE {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (LIKE {TARGET_SCHEMA}.STEM_SOURCE);

--insert into stem_source from cancer_longitude 
--map (Histology/Behaviour-ICD10) by ICDO3
WITH cte0 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select 
		t1.eid, 
		t2.visit_occurrence_id,
		t2.visit_detail_id,
		t1.p40005, 
		t1.p40006,  
		t1.p40011, 
		t1.p40012,  
		COALESCE(lkup.description, t1.p40021),
		t1.id
	from {SOURCE_SCHEMA}.cancer_longitude as t1
	join cte0 on t1.eid = cte0.person_id
	left join {SOURCE_SCHEMA}.lookup1970 as lkup on t1.p40021 = lkup.code
	join {TARGET_SCHEMA}.visit_detail as t2 on t1.eid = t2.person_id and t2.visit_detail_start_date = t1.p40005 and t2.visit_detail_source_value = COALESCE(lkup.description, t1.p40021)
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
	stem_source_table,
	stem_source_id
)
select distinct
	t1.eid as person_id, 
	t1.visit_occurrence_id,
	t1.visit_detail_id,
	t2.source_code as source_value,
	COALESCE(t2.source_concept_id, 0) as source_concept_id,
	32879 as type_concept_id,
	t1.p40005 as start_date,
	t1.p40005 as end_date,
	'00:00:00'::time start_time,
	'cancer-Histology' as stem_source_table,
	t1.id as stem_source_id
from cte1 as t1
join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on 
(t1.p40011 || '/' || t1.p40012 || '-' || t1.p40006 ) = REPLACE(t2.source_code, '.', '') and t2.source_vocabulary_id = 'ICDO3'
where t2.target_domain_id = 'Condition';


-- map (Histology/Behaviour) by ICDO3 
-- map (Topography) 
WITH cte0 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), base as(
	select 
		t1.eid, 
		t2.visit_occurrence_id,
		t2.visit_detail_id,
		t1.p40005,
		t1.p40006,  
		t1.p40013,
		t1.p40011 || '/' || t1.p40012 as source_value,
		COALESCE(lkup.description, t1.p40021),
		t1.id
	from {SOURCE_SCHEMA}.cancer_longitude as t1
	join cte0 on t1.eid = cte0.person_id
	left join {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} as t3 on t1.id = t3.stem_source_id::numeric
	left join {SOURCE_SCHEMA}.lookup1970 as lkup on t1.p40021 = lkup.code
	join {TARGET_SCHEMA}.visit_detail as t2 on t1.eid = t2.person_id and t2.visit_detail_start_date = t1.p40005 and t2.visit_detail_source_value = COALESCE(lkup.description, t1.p40021)
	where t1.p40011 is not null and  t1.p40012 is not null
	and t3.stem_source_id is null 
	
), cte1 as(
	select distinct
		t1.eid as person_id, 
		t1.visit_occurrence_id,
		t1.visit_detail_id,
		COALESCE(t2.source_code, t1.source_value) as source_value,
		COALESCE(t2.source_concept_id, 0) as source_concept_id,
		32879 as type_concept_id,
		t1.p40005 as start_date,
		t1.p40005 as end_date,
		'00:00:00'::time start_time,
		'cancer-Histology' as stem_source_table,
		t1.id as stem_source_id
	from base as t1
	join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t1.source_value = t2.source_code and t2.source_vocabulary_id = 'ICDO3' and t2.target_domain_id = 'Condition'

	UNION

	-- 'cancer-Topography'
	select distinct 
		t1.eid as person_id, 
		t1.visit_occurrence_id,
		t1.visit_detail_id,
		COALESCE(t2.source_code, t3.source_code, t4.source_code, t1.p40006, t1.p40013) as source_value,
		CASE 
			WHEN COALESCE(t1.p40006, t1.p40013) is NULL THEN NULL
			ELSE COALESCE(t4.source_concept_id, t3.source_concept_id, t2.source_concept_id,  0) 
		END as source_concept_id,
		32879 as type_concept_id,
		t1.p40005 as start_date,
		t1.p40005 as end_date,
		'00:00:00'::time start_time,
		'cancer-Topography' as stem_source_table,
		t1.id as stem_source_id
	from base as t1
	join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t5 on t1.source_value = t5.source_code and t5.source_vocabulary_id = 'ICDO3' and t5.target_domain_id = 'Condition'
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on COALESCE(t1.p40006, t1.p40013) = Replace(t2.source_code, '.', '') and t2.source_vocabulary_id in ('ICDO3')
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.p40006 = Replace(t3.source_code, '.', '') and t3.source_vocabulary_id ='ICD10'
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.p40013 = Replace(t4.source_code, '.', '') and t4.source_vocabulary_id ='ICD9CM'
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
	stem_source_table,
	stem_source_id
)
select distinct * from cte1
where source_value is not null;


-- Histology/Behaviour-NULL
WITH cte0 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), base as(
	select 
		t1.eid, 
		t2.visit_occurrence_id,
		t2.visit_detail_id,
		t1.p40005, 
		t1.p40006,  
		t1.p40013, 
		t1.p40011 || '/' || t1.p40012 as source_value,
		COALESCE(lkup.description, t1.p40021),
		t1.id
	from {SOURCE_SCHEMA}.cancer_longitude as t1
	join cte0 on t1.eid = cte0.person_id
	left join {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} as t3 on t1.id = t3.stem_source_id::numeric
	left join {SOURCE_SCHEMA}.lookup1970 as lkup on t1.p40021 = lkup.code
	join {TARGET_SCHEMA}.visit_detail as t2 on t1.eid = t2.person_id and t2.visit_detail_start_date = t1.p40005 and t2.visit_detail_source_value = COALESCE(lkup.description, t1.p40021)
	where t1.p40011 is not null and  t1.p40012 is not null
	and t3.stem_source_id is null
), cte1 as(
	select 
		t1.eid as person_id, 
		t1.visit_occurrence_id,
		t1.visit_detail_id,
		COALESCE(t2.source_code, t3.source_code, t1.source_value) as source_value,
		COALESCE(t2.source_concept_id, t3.source_concept_id, 0) as source_concept_id,
		32879 as type_concept_id,
		t1.p40005 as start_date,
		t1.p40005 as end_date,
		'00:00:00'::time start_time,
		CASE
			WHEN t3.target_domain_id = 'Measurement' THEN 'cancer-Behaviour' 
			ELSE 'cancer-Histology' 
		END as stem_source_table,
		t1.id as stem_source_id
	from base as t1
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on (t1.source_value || '-NULL') = t2.source_code and t2.source_vocabulary_id = 'ICDO3' and t2.target_domain_id = 'Condition'
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.source_value = t3.source_code and t3.source_vocabulary_id = 'CANCER_ICDO3_STCM' and t3.target_domain_id in ('Condition', 'Measurement')

	UNION

	-- 'cancer-Topography'
	select 
		t1.eid as person_id, 
		t1.visit_occurrence_id,
		t1.visit_detail_id,
		COALESCE(t2.source_code, t3.source_code, t4.source_code, t1.p40006, t1.p40013) as source_value,
		CASE 
			WHEN COALESCE(t1.p40006, t1.p40013) is NULL THEN NULL
			ELSE COALESCE(t4.source_concept_id, t3.source_concept_id, t2.source_concept_id,  0) 
		END as source_concept_id,
		32879 as type_concept_id,
		t1.p40005 as start_date,
		t1.p40005 as end_date,
		'00:00:00'::time start_time,
		'cancer-Topography' as stem_source_table,
		t1.id as stem_source_id
	from base as t1
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on COALESCE(t1.p40006, t1.p40013) = Replace(t2.source_code, '.', '') and t2.source_vocabulary_id in ('ICDO3')
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.p40006 = Replace(t3.source_code, '.', '') and t3.source_vocabulary_id ='ICD10'
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.p40013 = Replace(t4.source_code, '.', '') and t4.source_vocabulary_id ='ICD9CM'
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
	stem_source_table,
	stem_source_id
)
select distinct * from cte1
where source_value is not null;

-- map Histology/Behaviour is null
-- p40013 as Histology

WITH cte0 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), base as(
	select 
		t1.eid, 
		t2.visit_occurrence_id,
		t2.visit_detail_id,
		t1.p40005, 
		t1.p40006,  
		t1.p40013, 
		t1.p40011 || '/' || t1.p40012 as source_value,
		COALESCE(lkup.description, t1.p40021),
		t1.id
	from {SOURCE_SCHEMA}.cancer_longitude as t1
	join cte0 on t1.eid = cte0.person_id
	left join {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} as t3 on t1.id = t3.stem_source_id::numeric
	left join {SOURCE_SCHEMA}.lookup1970 as lkup on t1.p40021 = lkup.code
	join {TARGET_SCHEMA}.visit_detail as t2 on t1.eid = t2.person_id and t2.visit_detail_start_date = t1.p40005 and t2.visit_detail_source_value = COALESCE(lkup.description, t1.p40021)
	where t1.p40011 is null and  t1.p40012 is null --and COALESCE(t1.p40006, t1.p40013) is not null
	and t3.stem_source_id is null
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
	stem_source_table,
	stem_source_id
)
select 
	t1.eid as person_id, 
	t1.visit_occurrence_id,
	t1.visit_detail_id,
	COALESCE(t2.source_code, t3.source_code, t4.source_code, t1.p40006, t1.p40013) as source_value,
	CASE 
		WHEN COALESCE(t1.p40006, t1.p40013) is NULL THEN NULL
		ELSE COALESCE(t4.source_concept_id, t3.source_concept_id, t2.source_concept_id,  0) 
	END as source_concept_id,
	32879 as type_concept_id,
	t1.p40005 as start_date,
	t1.p40005 as end_date,
	'00:00:00'::time start_time,
	CASE 
		WHEN COALESCE(t4.source_concept_id, t3.source_concept_id, t2.source_concept_id) is not null 
			and COALESCE(t4.target_domain_id, t3.target_domain_id, t2.target_domain_id)= 'Condition' 
			and COALESCE(t4.target_concept_class_id, t3.target_concept_class_id, t2.target_concept_class_id) = 'Disorder' 
			THEN 'cancer-Histology' 
		ELSE 'cancer-Topography' 
	END as stem_source_table,
	t1.id as stem_source_id
from base as t1
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on COALESCE(t1.p40006, t1.p40013) = Replace(t2.source_code, '.', '') and t2.source_vocabulary_id in ('ICDO3')
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.p40006 = Replace(t3.source_code, '.', '') and t3.source_vocabulary_id ='ICD10'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.p40013 = Replace(t4.source_code, '.', '') and t4.source_vocabulary_id ='ICD9CM';

create index idx_stem_source_{CHUNK_ID}_1 on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (source_concept_id);
create index idx_stem_source_{CHUNK_ID}_2 on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (source_value);

-----------------------------------------
-- UPDATE CHUNK
-----------------------------------------
update {CHUNK_SCHEMA}.chunk 
set stem_source_tbl = concat('stem_source_',{CHUNK_ID}::varchar)
where chunk_id = {CHUNK_ID};