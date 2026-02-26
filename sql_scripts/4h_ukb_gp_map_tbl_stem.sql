CREATE TABLE {CHUNK_SCHEMA}.stem_{CHUNK_ID} (LIKE {TARGET_SCHEMA}.STEM) TABLESPACE pg_default;

--insert into stem from stem_source, this is the Athena vocab mapping portion
insert into {CHUNK_SCHEMA}.stem_{CHUNK_ID} (
	domain_id, 
	person_id, 
	visit_occurrence_id, 
	visit_detail_id, 
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
	value_as_number,
	value_as_string, 
	value_as_concept_id,
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
	nextval('{CHUNK_SCHEMA}.stem_id_seq') as id,
	COALESCE(t2.target_concept_id, 0) as concept_id,
	t1.source_value,
	t1.source_concept_id,
	t1.type_concept_id,
	t1.start_date,
	t1.end_date,
	t1.start_time,
	CASE 
		WHEN t2.target_domain_id = 'Drug' and t2.target_vocabulary_id = 'CVX' THEN 1
		WHEN t2.target_domain_id = 'Drug' and (lower(t2.target_concept_name) like '%vaccine%' or lower(t2.source_code_description) like '%vaccine%') THEN 1
		else t1.value_as_number
	END AS quantity,
	t1.days_supply,
	t1.range_high,
	t1.range_low,
	t1.operator_concept_id,
	t1.unit_concept_id,
	t1.unit_source_value,
	t1.unit_source_concept_id,
	t1.value_as_number,
	t1.value_as_string,
	CASE 
		WHEN t2.target_domain_id <> 'Measurement' THEN COALESCE(t3.concept_id, t1.value_as_concept_id)
		WHEN t2.target_domain_id = 'Measurement' and t3.domain_id = 'Meas Value' THEN t3.concept_id 
	END as value_as_concept_id,
	CASE WHEN t2.target_domain_id = 'Measurement' and t3.domain_id <> 'Meas Value' THEN COALESCE(t3.concept_name, t1.value_as_string) END as value_source_value, 
	t1.qualifier_source_value,
	t1.qualifier_concept_id,
	t1.stem_source_table,
	t1.stem_source_id
from {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} as t1
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_vocabulary_id = 'Read' and t1.source_concept_id = t2.source_concept_id
left join {VOCABULARY_SCHEMA}.concept as t3 on t3.vocabulary_id = 'Read' and t1.value_as_string = t3.concept_code
where t1.source_concept_id <> 0
and t1.stem_source_table = 'gp_clinical';

--insert into stem from stem_source, this is the STCM mapping portion + map to 0
insert into {CHUNK_SCHEMA}.stem_{CHUNK_ID} (
	domain_id, 
	person_id, 
	visit_occurrence_id, 
	visit_detail_id, 
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
	value_as_number,
	value_as_string, 
	value_as_concept_id,
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
	nextval('{CHUNK_SCHEMA}.stem_id_seq') as id,
	COALESCE(t2.target_concept_id, 0) as concept_id,
	t1.source_value,
	t1.source_concept_id,
	t1.type_concept_id,
	t1.start_date,
	t1.end_date,
	t1.start_time,
	CASE 
		WHEN t2.target_domain_id = 'Drug' and t2.target_vocabulary_id = 'CVX' THEN 1
		WHEN t2.target_domain_id = 'Drug' and (lower(t2.target_concept_name) like '%vaccine%' or lower(t2.source_code_description) like '%vaccine%') THEN 1
		else t1.value_as_number
	END AS quantity,
	t1.days_supply,
	t1.range_high,
	t1.range_low,
	t1.operator_concept_id,
	t1.unit_concept_id, 
	t1.unit_source_value,
	t1.unit_source_concept_id,
	t1.value_as_number,
	t1.value_as_string, 
	CASE 
		WHEN t2.target_domain_id <> 'Measurement' THEN COALESCE(t3.concept_id, t1.value_as_concept_id)
		WHEN t2.target_domain_id = 'Measurement' and t3.domain_id = 'Meas Value' THEN t3.concept_id 
	END as value_as_concept_id,
	CASE WHEN t2.target_domain_id = 'Measurement' and t3.domain_id <> 'Meas Value' THEN COALESCE(t3.concept_name, t1.value_as_string) END as value_source_value,
	t1.qualifier_source_value,
	t1.qualifier_concept_id,
	t1.stem_source_table,
	t1.stem_source_id
from {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} as t1
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_vocabulary_id = 'UKB_GP_CLINICAL_READ_STCM' and t1.source_value = t2.source_code
left join {VOCABULARY_SCHEMA}.concept as t3 on t3.vocabulary_id = 'Read' and t1.value_as_string = t3.concept_code
where t1.source_concept_id = 0
and t1.stem_source_table = 'gp_clinical';


insert into {CHUNK_SCHEMA}.stem_{CHUNK_ID} (
	domain_id, 
	person_id, 
	visit_occurrence_id, 
	visit_detail_id, 
	id, 
	concept_id, 
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	days_supply, 
	sig, 
	quantity,  
	unit_concept_id,
	unit_source_value, 
	unit_source_concept_id,	  
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
	nextval('{CHUNK_SCHEMA}.stem_id_seq') as id,
	COALESCE(t2.target_concept_id, 0) as concept_id,
	t1.source_value,
	t1.source_concept_id,
	t1.type_concept_id,
	t1.start_date,
	t1.end_date + COALESCE(t1.days_supply, 0),
	t1.start_time,
	t1.days_supply,
	t1.sig,
	CASE 
		WHEN t2.target_domain_id = 'Drug' and t2.target_vocabulary_id = 'CVX' THEN 1
		WHEN t2.target_domain_id = 'Drug' and (lower(t2.target_concept_name) like '%vaccine%' or lower(t2.source_code_description) like '%vaccine%') THEN 1
		else t1.quantity
	END AS quantity,
	t1.unit_concept_id,
	t1.unit_source_value, 
	t1.unit_source_concept_id, 
	t1.stem_source_table,
	t1.stem_source_id
from {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} as t1
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t1.source_value = t2.source_code and t2.source_vocabulary_id in ('UKB_GP_SCRIPT_DRUG_STCM', 'UKB_GP_SCRIPT_READ_STCM')
where t1.stem_source_table = 'gp_scripts';

ALTER TABLE {CHUNK_SCHEMA}.stem_{CHUNK_ID} ADD CONSTRAINT pk_stem_{CHUNK_ID} PRIMARY KEY (id) USING INDEX TABLESPACE pg_default;
create index idx_stem_{CHUNK_ID}_1 on {CHUNK_SCHEMA}.stem_{CHUNK_ID} (domain_id) TABLESPACE pg_default;
create index idx_stem_{CHUNK_ID}_2 on {CHUNK_SCHEMA}.stem_{CHUNK_ID} (unit_source_value) TABLESPACE pg_default;
create index idx_stem_{CHUNK_ID}_3 on {CHUNK_SCHEMA}.stem_{CHUNK_ID} (source_value) TABLESPACE pg_default;
create index idx_stem_{CHUNK_ID}_4 on {CHUNK_SCHEMA}.stem_{CHUNK_ID} (stem_source_table, stem_source_id) TABLESPACE pg_default;

-- link corresponding records to measurement
With _measurement AS(
	select id, stem_source_table, stem_source_id
	from {CHUNK_SCHEMA}.stem_{CHUNK_ID}
	where domain_id = 'Measurement'
), _others AS(
	select 	id, 
			CASE 
				WHEN domain_id = 'Condition' THEN 1147127
				WHEN domain_id = 'Procedure' THEN 1147082
				WHEN domain_id = 'Observation' THEN 1147165
			END as event_field_concept_id,
			stem_source_table, 
			stem_source_id 
	from {CHUNK_SCHEMA}.stem_{CHUNK_ID}
	where domain_id in ('Condition', 'Observation', 'Procedure')
), cte as(
	select  
		t1.id, 
		t2.id as measurement_event_id,
		t2.event_field_concept_id as meas_event_field_concept_id
	from _measurement as t1
	join _others as t2 on t1.stem_source_table = t2.stem_source_table and t1.stem_source_id = t2.stem_source_id
)
UPDATE {CHUNK_SCHEMA}.stem_{CHUNK_ID} as t1
SET measurement_event_id = cte.measurement_event_id, 
	meas_event_field_concept_id = cte.meas_event_field_concept_id
FROM cte
WHERE t1.id = cte.id;

-- linking corresponding records to observation
With _observation AS(
	select id, stem_source_table, stem_source_id
	from {CHUNK_SCHEMA}.stem_{CHUNK_ID}
	where domain_id = 'Observation'
), _others AS(
	select 	id,
			CASE 
				WHEN domain_id = 'Condition' THEN 1147127
				WHEN domain_id = 'Observation' THEN 1147165 
				WHEN domain_id = 'Procedure' THEN 1147082
				WHEN domain_id = 'Measurement' THEN 1147138
			END as event_field_concept_id,
			stem_source_table, stem_source_id 
	from {CHUNK_SCHEMA}.stem_{CHUNK_ID} 
	where domain_id in ('Condition', 'Observation', 'Procedure', 'Measurement')
), cte as(
	select  
		t1.id, 
		t2.id as observation_event_id,
		t2.event_field_concept_id as obs_event_field_concept_id
	from _observation as t1
	join _others as t2 on t1.stem_source_table = t2.stem_source_table and t1.stem_source_id = t2.stem_source_id
	and t1.id <> t2.id
)
UPDATE {CHUNK_SCHEMA}.stem_{CHUNK_ID} as t1
SET observation_event_id = cte.observation_event_id, 
	obs_event_field_concept_id = cte.obs_event_field_concept_id
FROM cte
WHERE t1.id = cte.id;

-----------------------------------------
-- UPDATE CHUNK
-----------------------------------------
update {CHUNK_SCHEMA}.chunk 
set 
stem_tbl = concat('stem_',{CHUNK_ID}::varchar),
stem_id_start = (SELECT MIN(id) FROM {CHUNK_SCHEMA}.stem_{CHUNK_ID}),
stem_id_end = (SELECT MAX(id) FROM {CHUNK_SCHEMA}.stem_{CHUNK_ID})
where chunk_id = {CHUNK_ID};