CREATE TABLE {CHUNK_SCHEMA}.stem_{CHUNK_ID} (LIKE {TARGET_SCHEMA}.STEM) TABLESPACE pg_default;

--insert into stem from stem_source, this is the Athena vocab mapping portion
insert into {CHUNK_SCHEMA}.stem_{CHUNK_ID} (
	domain_id, 
	person_id, 
	visit_occurrence_id, 
	visit_detail_id, 
	provider_id, 
	id, 
	concept_id, 
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	quantity,
	days_supply, 
	range_high, 
	range_low, 
	operator_concept_id,	
	unit_concept_id,
	unit_source_value, 
	unit_source_concept_id,
	value_as_concept_id, 
	value_as_number,
	value_as_string, 
	value_source_value,
	qualifier_source_value,
	qualifier_concept_id,	
	stem_source_table, 
	stem_source_id
)
select distinct
	case 
		when t2.target_domain_id is NULL then 'Observation'			
		else t2.target_domain_id
	end as domain_id,
	t1.person_id,
	t1.visit_occurrence_id,
	t1.visit_detail_id,
	t1.provider_id,
	nextval('{CHUNK_SCHEMA}.stem_id_seq') as id,
	COALESCE(t2.target_concept_id, 0) as concept_id,
	t1.source_value,
	CASE
		WHEN t2.source_code <> t1.source_value THEN 0
		ELSE t1.source_concept_id
	END as source_concept_id,
	t1.type_concept_id,
	t1.start_date,
	t1.end_date,
	t1.start_time,
	t1.quantity,
	t1.days_supply,
	t1.range_high,
	t1.range_low,
	t1.operator_concept_id,
	t1.unit_concept_id,
	t1.unit_source_value,
	t1.unit_source_concept_id,
	t1.value_as_concept_id, 
	t1.value_as_number,
	t1.value_as_string,
	t1.value_source_value, 
	t1.qualifier_source_value,
	t1.qualifier_concept_id,
	t1.stem_source_table,
	t1.stem_source_id
from {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} as t1
join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t1.source_concept_id = t2.source_concept_id
where t1.source_concept_id <> 0;


-- insert /behavour code in (1,5,6,9)
insert into {CHUNK_SCHEMA}.stem_{CHUNK_ID} (
	domain_id, 
	person_id, 
	visit_occurrence_id, 
	visit_detail_id, 
	provider_id, 
	id, 
	concept_id, 
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	quantity,
	days_supply, 
	range_high, 
	range_low, 
	operator_concept_id,	
	unit_concept_id,
	unit_source_value, 
	unit_source_concept_id,
	value_as_concept_id, 
	value_as_number,
	value_as_string, 
	value_source_value,
	qualifier_source_value,
	qualifier_concept_id,	
	stem_source_table, 
	stem_source_id
)
select distinct
	case 
		when t2.target_domain_id is NULL then 'Observation'			
		else t2.target_domain_id
	end as domain_id,
	t1.person_id,
	t1.visit_occurrence_id,
	t1.visit_detail_id,
	t1.provider_id,
	nextval('{CHUNK_SCHEMA}.stem_id_seq') as id,
	COALESCE(t3.target_concept_id, t4.target_concept_id, t5.target_concept_id, t6.target_concept_id, 0) as concept_id,
	t1.source_value,
	0 as source_concept_id,
	t1.type_concept_id,
	t1.start_date,
	t1.end_date,
	t1.start_time,
	t1.quantity,
	t1.days_supply,
	t1.range_high,
	t1.range_low,
	t1.operator_concept_id,
	t1.unit_concept_id,
	t1.unit_source_value,
	t1.unit_source_concept_id,
	t1.value_as_concept_id, 
	t1.value_as_number,
	t1.value_as_string,
	t1.value_source_value, 
	t1.qualifier_source_value,
	t1.qualifier_concept_id,
	'cancer-Behaviour' as stem_source_table,
	t1.stem_source_id
from {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} as t1
join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t1.source_concept_id = t2.source_concept_id
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t3.source_concept_id = 432851 and t1.source_value like '%/6'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t4.source_concept_id = 4173160 and t1.source_value like '%/5'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t5 on t5.source_concept_id = 4268747 and t1.source_value like '%/9'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t6 on t6.source_concept_id = 42512996 and t1.source_value like '%/1'
where t1.source_concept_id <> 0
and t1.stem_source_table = 'cancer-Histology'
and t2.source_code <> t1.source_value
and LEFT(t2.source_code,6) <> t1.source_value;


--insert into stem from stem_source, this is the STCM mapping portion + map to 0
insert into {CHUNK_SCHEMA}.stem_{CHUNK_ID} (
	domain_id, 
	person_id, 
	visit_occurrence_id, 
	visit_detail_id, 
	provider_id, 
	id, 
	concept_id, 
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	quantity,
	days_supply, 
	range_high, 
	range_low, 
	operator_concept_id,	
	unit_concept_id,
	unit_source_value, 
	unit_source_concept_id,
	value_as_concept_id, 
	value_as_number,
	value_as_string, 
	value_source_value,
	qualifier_source_value,
	qualifier_concept_id,	
	stem_source_table, 
	stem_source_id
)
select distinct
	case 
		when t2.target_domain_id is NULL then 'Observation'			
		else t2.target_domain_id
	end as domain_id,
	t1.person_id,
	t1.visit_occurrence_id,
	t1.visit_detail_id,
	t1.provider_id,
	nextval('{CHUNK_SCHEMA}.stem_id_seq') as id,
	COALESCE(t2.target_concept_id, 0) as concept_id,
	t1.source_value,
	COALESCE(t3.concept_id, t1.source_concept_id),
	t1.type_concept_id,
	t1.start_date,
	t1.end_date,
	t1.start_time,
	t1.quantity,
	t1.days_supply,
	t1.range_high,
	t1.range_low,
	t1.operator_concept_id,
	t1.unit_concept_id,
	t1.unit_source_value,
	t1.unit_source_concept_id,
	t1.value_as_concept_id, 
	t1.value_as_number,
	t1.value_as_string,
	t1.value_source_value, 
	t1.qualifier_source_value,
	t1.qualifier_concept_id,
	t1.stem_source_table,
	t1.stem_source_id
from {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} as t1
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_vocabulary_id = 'CANCER_ICDO3_STCM' and t1.source_value = t2.source_code and t2.target_domain_id = 'Condition'
left join {VOCABULARY_SCHEMA}.concept as t3 on t3.vocabulary_id = 'ICDO3' and t1.source_value = t3.concept_code
where t1.source_concept_id = 0
and t1.stem_source_table <> 'cancer-Behaviour';


ALTER TABLE {CHUNK_SCHEMA}.stem_{CHUNK_ID} ADD CONSTRAINT pk_stem_{CHUNK_ID} PRIMARY KEY (id) USING INDEX TABLESPACE pg_default;
create index idx_stem_{CHUNK_ID}_1 on {CHUNK_SCHEMA}.stem_{CHUNK_ID} (domain_id) TABLESPACE pg_default;
create index idx_stem_{CHUNK_ID}_2 on {CHUNK_SCHEMA}.stem_{CHUNK_ID} (stem_source_id) TABLESPACE pg_default;

-----------------------------------------
-- link Cancer Diagnosis to Measurement
-----------------------------------------
With _measurement AS(
	select id, stem_source_id
	from {CHUNK_SCHEMA}.stem_{CHUNK_ID}
	where domain_id = 'Measurement'
	--and stem_source_table = 'cancer-Behaviour'
), _condition AS(
	select 	
		id, 
		1147127 as event_field_concept_id, 
		stem_source_id 
	from {CHUNK_SCHEMA}.stem_{CHUNK_ID}
	where domain_id = 'Condition' and stem_source_table = 'cancer-Histology'
), cte as(
	select  
		t1.id, 
		t2.id as measurement_event_id,
		t2.event_field_concept_id as meas_event_field_concept_id
	from _measurement as t1
	join _condition as t2 on t1.stem_source_id = t2.stem_source_id
)
UPDATE {CHUNK_SCHEMA}.stem_{CHUNK_ID} as t1
SET measurement_event_id = cte.measurement_event_id, 
	meas_event_field_concept_id = cte.meas_event_field_concept_id
FROM cte
WHERE t1.id = cte.id;

-----------------------------------------
-- EPISODE
-----------------------------------------
-- Disease Episode
insert into {CHUNK_SCHEMA}.stem_{CHUNK_ID} (
	domain_id, 
	person_id, 
	id, 
	concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_concept_id, 
	source_value,
	source_concept_id, 
	stem_source_table, 
	stem_source_id
)
select distinct
	'Episode' as domain_id,
	person_id, 
	nextval('{CHUNK_SCHEMA}.stem_id_seq') as id, 	--episode_id
	32533 as concept_id, 							--episode_concept_id: Disease Episode
	32879 as type_concept_id, 						--episode_type_concept_id
	start_date as start_date,						--episode_start_date
	NULL::date as end_date,							--episode_end_date
	'00:00:00'::time as start_time,	
	concept_id as value_as_concept_id,				--episode_object_concept_id
	source_value,									--episode_source_value
	source_concept_id, 								--episode_source_concept_id
	stem_source_table,
	stem_source_id
from {CHUNK_SCHEMA}.stem_{CHUNK_ID} 
where stem_source_table = 'cancer-Histology'
and domain_id = 'Condition';	

-----------------------------------------
-- UPDATE CHUNK
-----------------------------------------
update {CHUNK_SCHEMA}.chunk 
set 
stem_tbl = concat('stem_',{CHUNK_ID}::varchar),
stem_id_start = (SELECT MIN(id) FROM {CHUNK_SCHEMA}.stem_{CHUNK_ID}),
stem_id_end = (SELECT MAX(id) FROM {CHUNK_SCHEMA}.stem_{CHUNK_ID})
where chunk_id = {CHUNK_ID};
