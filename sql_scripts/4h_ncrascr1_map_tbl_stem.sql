CREATE TABLE {CHUNK_SCHEMA}.stem_{CHUNK_ID} (LIKE {TARGET_SCHEMA}.STEM);

--insert into stem from stem_source when source_concept_id <> 0
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
	t1.source_concept_id,
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
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t1.source_concept_id = t2.source_concept_id
--AND ((t1.stem_source_table = 'Tumour' AND t2.source_vocabulary_id = 'ICDO3')											--source_concept_id is PK.
--OR (t1.stem_source_table = 'Treatment' AND t2.source_vocabulary_id in ('OPCS4', 'RxNorm', 'RxNorm Extension')))
where t1.source_concept_id <> 0;


-- insert into stem from stem_source when source_concept_id = 0
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
	t1.source_concept_id,
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
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_vocabulary_id = 'NCRAS_STCM' 
and t1.source_value = t2.source_code 
where t1.source_concept_id = 0
and (stem_source_table in ('Tumour', 'Treatment', 'Tumour-Stage') 
or (regexp_match(stem_source_table, 'Tumour-[tnm]_'))[1] is not null);


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
	t1.source_concept_id,
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
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_vocabulary_id = 'NCRAS_TUMOUR_MODIFIER_STCM' 
and t1.source_value = t2.source_code 
where t1.source_concept_id = 0
and stem_source_table = ('Tumour-vitalstatus');


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
	t1.source_concept_id,
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
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_vocabulary_id = 'NCRAS_TUMOUR_MODIFIER_STCM' 
and t1.source_value = t2.source_code 
where t1.source_concept_id = 0
and stem_source_table = ('Tumour-Modifier');

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
	t1.source_concept_id,
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
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_vocabulary_id = 'NCRAS_TUMOUR_GRADE_STCM' 
and t1.source_value = t2.source_code 
where t1.source_concept_id = 0
and stem_source_table = ('Tumour-Grade');


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
	t1.source_concept_id,
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
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_vocabulary_id = 'NCRAS_TUMOUR_GLEASON_PRI_STCM' 
and t1.source_value = t2.source_code 
where t1.source_concept_id = 0
and stem_source_table = ('Tumour-Gleason Primary');

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
	t1.source_concept_id,
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
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_vocabulary_id = 'NCRAS_TUMOUR_GLEASON_SEC_STCM' 
and t1.source_value = t2.source_code 
where t1.source_concept_id = 0
and stem_source_table = ('Tumour-Gleason Secondary');

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
	t1.source_concept_id,
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
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_vocabulary_id = 'NCRAS_TUMOUR_GLEASON_TER_STCM' 
and t1.source_value = t2.source_code 
where t1.source_concept_id = 0
and stem_source_table = ('Tumour-Gleason Tertiary');


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
	t1.source_concept_id,
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
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_vocabulary_id = 'NCRAS_TREATMENT_MODIFIER_STCM' 
and t1.source_value = t2.source_code 
where t1.source_concept_id = 0
and stem_source_table = ('Treatment-Modifier');

ALTER TABLE {CHUNK_SCHEMA}.stem_{CHUNK_ID} ADD CONSTRAINT pk_stem_{CHUNK_ID} PRIMARY KEY (id);
create index idx_stem_{CHUNK_ID}_1 on {CHUNK_SCHEMA}.stem_{CHUNK_ID} (domain_id, stem_source_table);
create index idx_stem_{CHUNK_ID}_2 on {CHUNK_SCHEMA}.stem_{CHUNK_ID} (stem_source_id);
create index idx_stem_{CHUNK_ID}_3 on {CHUNK_SCHEMA}.stem_{CHUNK_ID} (unit_source_value);

-----------------------------------------
-- link Cancer Diagnosis to Measurement
-----------------------------------------
With _measurement AS(
	select id, stem_source_id
	from {CHUNK_SCHEMA}.stem_{CHUNK_ID}
	where domain_id = 'Measurement'
	and stem_source_table like 'Tumour-%'
), _others AS(
	select 	
		id, 
		CASE 
			WHEN domain_id = 'Condition' THEN 1147127
			WHEN domain_id = 'Observation' THEN 1147165
			WHEN domain_id = 'Procedure' THEN 1147082	
			WHEN domain_id = 'Drug' THEN 1147094
			-- Device
			-- Specimen
			ELSE 1147165
		END as event_field_concept_id, 
		stem_source_id 
	from {CHUNK_SCHEMA}.stem_{CHUNK_ID}
	where domain_id not in ('Episode', 'Measurement') and stem_source_table = 'Tumour'
), cte as(
	select  
		t1.id, 
		t2.id as measurement_event_id,
		t2.event_field_concept_id as meas_event_field_concept_id
	from _measurement as t1
	join _others as t2 on t1.stem_source_id = t2.stem_source_id
)
UPDATE {CHUNK_SCHEMA}.stem_{CHUNK_ID} as t1
SET measurement_event_id = cte.measurement_event_id, 
	meas_event_field_concept_id = cte.meas_event_field_concept_id
FROM cte
WHERE t1.id = cte.id;

-----------------------------------------
-- link Treatment to Measurement
-----------------------------------------
With _measurement AS(
	select id, stem_source_id
	from {CHUNK_SCHEMA}.stem_{CHUNK_ID}
	where domain_id = 'Measurement'
	and stem_source_table like 'Treatment-%'
), _others AS(
	select 	
		id, 
		CASE 
			WHEN domain_id = 'Condition' THEN 1147127
			WHEN domain_id = 'Observation' THEN 1147165
			WHEN domain_id = 'Procedure' THEN 1147082	
			WHEN domain_id = 'Drug' THEN 1147094
			-- Device
			-- Specimen
			ELSE 1147165
		END as event_field_concept_id, 
		stem_source_id 
	from {CHUNK_SCHEMA}.stem_{CHUNK_ID}
	where domain_id not in ('Episode', 'Measurement') and stem_source_table = 'Treatment'
), cte as(
	select  
		t1.id, 
		t2.id as measurement_event_id,
		t2.event_field_concept_id as meas_event_field_concept_id
	from _measurement as t1
	join _others as t2 on t1.stem_source_id = t2.stem_source_id
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
	stem_source_table,
	stem_source_id
from {CHUNK_SCHEMA}.stem_{CHUNK_ID} 
where stem_source_table = 'Tumour'
and domain_id = 'Condition';					

-- Treatment Regimen Episode
With cte0 as(
	select  distinct
	t1.person_id,
	t2.e_cr_id,
	t1.start_date,  
	t2.eventdesc,
	COALESCE(t5.target_concept_id, t6.target_concept_id) as value_as_concept_id,
	COALESCE(t5.target_domain_id, t6.target_domain_id) as target_domain_id,
	t1.stem_source_table,  
	t1.stem_source_id as treatment_id
	from {CHUNK_SCHEMA}.stem_{CHUNK_ID} as t1
	join {SOURCE_SCHEMA}.treatment as t2 on t2.treatment_id = t1.stem_source_id::numeric 
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t5 on t2.eventdesc = t5.source_code and t5.source_vocabulary_id = 'NCRAS_TREATMENT_EPISODE_STCM' 
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t6 on t2.eventdesc = t6.source_code and t6.source_vocabulary_id = 'NCRAS_STCM' 
	where t1.stem_source_table = 'Treatment'
)
insert into {CHUNK_SCHEMA}.stem_{CHUNK_ID} (
	domain_id, 
	person_id, 
	id, 
	source_concept_id,
	concept_id, 
	source_value,
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	value_as_concept_id, 	
	stem_source_table, 
	stem_source_id
)
select 
	'Episode' as domain_id,
	t1.person_id,
	nextval('{CHUNK_SCHEMA}.stem_id_seq') as id,	--episode_id
	t2.id as source_concept_id, 					--episode_parent_id,
	32531 as concept_id, 							--episode_concept_id: Treatment Regimen Episode					
	t1.eventdesc as source_value,					--episode_source_value
	32879 as type_concept_id, 						--episode_type_concept_id
	t1.start_date, 									--episode_start_date
	NULL::date as end_date,							--episode_end_date
	'00:00:00'::time as start_time,
	ROW_NUMBER () OVER (PARTITION BY t1.person_id ORDER BY t1.person_id, t1.start_date, t1.treatment_id) as value_as_number, --episode_number,
	t1.value_as_concept_id,							--episode_object_concept_id	
	t1.stem_source_table,
	t1.treatment_id as stem_source_id
from cte0 as t1
left join {CHUNK_SCHEMA}.stem_{CHUNK_ID} as t2 on t1.person_id = t2.person_id and t1.e_cr_id = t2.stem_source_id::numeric
where t2.concept_id = 32533  						-- link Treatment Regimen Episode to Disease Episode
and t1.value_as_concept_id is not null
and t1.target_domain_id in ('Regimen', 'Procedure');


-----------------------------------------
-- UPDATE CHUNK
-----------------------------------------
update {CHUNK_SCHEMA}.chunk 
set 
stem_tbl = concat('stem_',{CHUNK_ID}::varchar),
stem_id_start = (SELECT MIN(id) FROM {CHUNK_SCHEMA}.stem_{CHUNK_ID}),
stem_id_end = (SELECT MAX(id) FROM {CHUNK_SCHEMA}.stem_{CHUNK_ID})
where chunk_id = {CHUNK_ID};
