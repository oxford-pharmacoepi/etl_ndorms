CREATE TABLE {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (LIKE {TARGET_SCHEMA}.STEM_SOURCE);

--insert into stem_source from cancer2 --duplication exists
--map (Histology/Behaviour-ICD10/9) by ICDO3
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
		t1.p40008, 
		t1.p40011, 
		t1.p40012, 
		t1.p40013, 
		COALESCE(lkup.description, t1.p40021),
		min(t1.id) as id
	from {SOURCE_SCHEMA}.cancer2 as t1
	join cte0 on t1.eid = cte0.person_id
	left join {SOURCE_SCHEMA}.lookup1970 as lkup on t1.p40021 = lkup.code
	join {TARGET_SCHEMA}.visit_detail as t2 on t1.eid = t2.person_id and t2.visit_detail_start_date = t1.p40005 and t2.visit_detail_source_value = COALESCE(lkup.description, t1.p40021)
	group by t1.eid, t2.visit_occurrence_id, t2.visit_detail_id, t1.p40005, t1.p40006, t1.p40008, t1.p40011, t1.p40012, t1.p40013, COALESCE(lkup.description, t1.p40021)
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
	'cancer2' as stem_source_table,
	t1.id as stem_source_id
from base as t1
join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on 
(t1.p40011 || '/' || t1.p40012 || '-' || COALESCE(t1.p40006, t1.p40013) ) = REPLACE(t2.source_code, '.', '') and t2.source_vocabulary_id = 'ICDO3';

-- map (Histology/Behaviour) by ICDO3
-- map -Type of cancer(ICD code) by ICD10 or ICD9CM or ICDO3
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
		t1.p40008, 
		t1.p40011, 
		t1.p40012, 
		t1.p40013, 
		COALESCE(lkup.description, t1.p40021),
		min(t1.id) as id
	from {SOURCE_SCHEMA}.cancer2 as t1
	join cte0 on t1.eid = cte0.person_id
	left join {SOURCE_SCHEMA}.lookup1970 as lkup on t1.p40021 = lkup.code
	join {TARGET_SCHEMA}.visit_detail as t2 on t1.eid = t2.person_id and t2.visit_detail_start_date = t1.p40005 and t2.visit_detail_source_value = COALESCE(lkup.description, t1.p40021)
	group by t1.eid, t2.visit_occurrence_id, t2.visit_detail_id, t1.p40005, t1.p40006, t1.p40008, t1.p40011, t1.p40012, t1.p40013, COALESCE(lkup.description, t1.p40021)
), cte1 as(
	select 
		t1.eid as person_id, 
		t1.visit_occurrence_id,
		t1.visit_detail_id,
		COALESCE(t2.source_code, t3.source_code, (t1.p40011 || '/' || t1.p40012 )) as source_value,
		COALESCE(t2.source_concept_id, t3.source_concept_id, 0) as source_concept_id,
		32879 as type_concept_id,
		t1.p40005 as start_date,
		t1.p40005 as end_date,
		'00:00:00'::time start_time,
		'cancer2' as stem_source_table,
		t1.id as stem_source_id
	from base as t1
	left join {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} as t on t1.id = t.stem_source_id::numeric
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on (t1.p40011 || '/' || t1.p40012 ) = t2.source_code and t2.source_vocabulary_id = 'ICDO3'
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on (t1.p40011 || '/' || t1.p40012 ) = t3.source_code and t3.source_vocabulary_id = 'CANCER_ICDO3_STCM'
	where t.stem_source_id is null

	UNION

	select 
		t1.eid as person_id, 
		t1.visit_occurrence_id,
		t1.visit_detail_id,
		COALESCE(t4.source_code, t3.source_code, t2.source_code, t1.p40006, t1.p40013) as source_value,
		CASE 
			WHEN COALESCE(t1.p40006, t1.p40013) is NULL THEN NULL
			ELSE COALESCE(t4.source_concept_id, t3.source_concept_id, t2.source_concept_id,  0) 
		END as source_concept_id,
		32879 as type_concept_id,
		t1.p40005 as start_date,
		t1.p40005 as end_date,
		'00:00:00'::time start_time,
		'cancer2' as stem_source_table,
		t1.id as stem_source_id
	from base as t1
	left join {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} as t on t1.id = t.stem_source_id::numeric
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t1.p40006 = Replace(t2.source_code, '.', '') and t2.source_vocabulary_id ='ICD10'
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.p40013 = Replace(t3.source_code, '.', '') and t3.source_vocabulary_id ='ICD9CM'
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on COALESCE(t1.p40006, t1.p40013) = Replace(t4.source_code, '.', '') and t4.source_vocabulary_id in ('ICDO3')
	where t.stem_source_id is null
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
select distinct *
from cte1
where source_value is not null;

create index idx_stem_source_{CHUNK_ID}_1 on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (source_concept_id);
create index idx_stem_source_{CHUNK_ID}_2 on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (source_value);


-----------------------------------------
-- UPDATE CHUNK
-----------------------------------------
update {CHUNK_SCHEMA}.chunk 
set stem_source_tbl = concat('stem_source_',{CHUNK_ID}::varchar)
where chunk_id = {CHUNK_ID};