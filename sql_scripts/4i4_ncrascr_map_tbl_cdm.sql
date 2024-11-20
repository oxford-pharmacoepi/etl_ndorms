--------------------------------
-- insert into condition_occurrence from stem
--------------------------------
with cte0 AS (
	SELECT max_id + 1 as start_id from {TARGET_SCHEMA_TO_LINK}._max_ids 
	WHERE lower(tbl_name) = 'max_of_all'
),
cte1 as (
	SELECT cte0.start_id + id as condition_occurrence_id,
		person_id,
		concept_id as condition_concept_id,
		start_date as condition_start_date,
		start_date as condition_start_datetime,
		end_date as condition_end_date,
		end_date as condition_end_datetime,
		type_concept_id as condition_type_concept_id,
		NULL::int as condition_status_concept_id, 
		stop_reason,
		provider_id,
		visit_occurrence_id,
		visit_detail_id,
		source_value as condition_source_value,
		source_concept_id as condition_source_concept_id,
		NULL as condition_status_source_value
	from cte0, {CHUNK_SCHEMA}.stem_{CHUNK_ID}
	where domain_id = 'Condition'
)
insert into {TARGET_SCHEMA}.condition_occurrence(condition_occurrence_id, person_id, condition_concept_id, condition_start_date,
												  condition_start_datetime, condition_end_date, condition_end_datetime,
												  condition_type_concept_id, condition_status_concept_id, stop_reason, provider_id,
												  visit_occurrence_id, visit_detail_id, condition_source_value, condition_source_concept_id,
												  condition_status_source_value)
select * from cte1;

--------------------------------
--insert into drug_exposure from stem
--------------------------------
with cte0 AS (
	SELECT max_id  + 1 as start_id from {TARGET_SCHEMA_TO_LINK}._max_ids 
	WHERE lower(tbl_name) = 'max_of_all'
),
cte2 as (
	SELECT cte0.start_id + id as drug_exposure_id,
		person_id,
		concept_id as drug_concept_id,
		start_date as drug_exposure_start_date,
		start_date as drug_exposure_start_datetime,
		end_date as drug_exposure_end_date,
		end_date as drug_exposure_end_datetime,
		NULL::date as verbatim_end_date,
		type_concept_id as drug_type_concept_id,
		stop_reason,
		refills,
		quantity,
		days_supply,
		sig,
		route_concept_id,
		lot_number,
		provider_id,
		visit_occurrence_id,
		visit_detail_id,
		source_value as drug_source_value,
		source_concept_id as drug_source_concept_id,
		route_source_value,
		dose_unit_source_value
	from cte0, {CHUNK_SCHEMA}.stem_{CHUNK_ID}
	where domain_id = 'Drug'
)
insert into {TARGET_SCHEMA}.drug_exposure(drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date,
											drug_exposure_start_datetime, drug_exposure_end_date, drug_exposure_end_datetime,
											verbatim_end_date, drug_type_concept_id, stop_reason, refills, quantity, days_supply,
											sig, route_concept_id, lot_number, provider_id, visit_occurrence_id, visit_detail_id,
											drug_source_value, drug_source_concept_id, route_source_value, dose_unit_source_value)
select * from cte2;

--------------------------------
--insert into device_exposure from stem
--------------------------------
with cte0 AS (
	SELECT max_id  + 1 as start_id from {TARGET_SCHEMA_TO_LINK}._max_ids 
	WHERE lower(tbl_name) = 'max_of_all'
),
cte4 as (
	SELECT cte0.start_id + s.id as device_exposure_id,
		person_id,
		concept_id as device_concept_id,
		start_date as device_exposure_start_date,
		start_date as device_exposure_start_datetime,
		end_date as device_exposure_end_date,
		end_date as device_exposure_end_datetime,
		type_concept_id as device_type_concept_id,
		unique_device_id,
		NULL as production_id,
		quantity,
		provider_id,
		visit_occurrence_id,
		visit_detail_id,
		source_value as device_source_value,
		source_concept_id as device_source_concept_id,
		unit_concept_id,  
		unit_source_value, 
		unit_source_concept_id
	from cte0, {CHUNK_SCHEMA}.stem_{CHUNK_ID} s
	where domain_id = 'Device'
)
insert into {TARGET_SCHEMA}.device_exposure(device_exposure_id, person_id, device_concept_id, device_exposure_start_date,
											 device_exposure_start_datetime, device_exposure_end_date, device_exposure_end_datetime,
											 device_type_concept_id, unique_device_id, production_id, quantity, provider_id, visit_occurrence_id,
											 visit_detail_id, device_source_value, device_source_concept_id, unit_concept_id,  
											 unit_source_value, unit_source_concept_id)
select * from cte4;

--------------------------------
--insert into procedure_occurrence from stem
--------------------------------
with cte0 AS (
	SELECT max_id  + 1 as start_id from {TARGET_SCHEMA_TO_LINK}._max_ids 
	WHERE lower(tbl_name) = 'max_of_all'
),
cte5 as (
	SELECT cte0.start_id + id as procedure_occurrence_id,
		person_id,
		concept_id as procedure_concept_id,
		start_date as procedure_date,
		start_date as procedure_datetime,
		end_date as procedure_end_date,
		end_date as procedure_end_datetime,
		type_concept_id as procedure_type_concept_id,
		modifier_concept_id,
		1 AS quantity,
		provider_id,
		visit_occurrence_id,
		visit_detail_id,
		source_value as procedure_source_value,
		source_concept_id as procedure_source_concept_id,
		modifier_source_value
	from cte0, {CHUNK_SCHEMA}.stem_{CHUNK_ID}
	where domain_id = 'Procedure'
)
insert into {TARGET_SCHEMA}.procedure_occurrence(procedure_occurrence_id, person_id, procedure_concept_id, procedure_date,
												  procedure_datetime, procedure_end_date, procedure_end_datetime, procedure_type_concept_id, modifier_concept_id, quantity,
												  provider_id, visit_occurrence_id, visit_detail_id, procedure_source_value,
												  procedure_source_concept_id, modifier_source_value)
select * from cte5;

--------------------------------
--insert into measurement from stem
--------------------------------
with cte0 AS (
	SELECT max_id  + 1 as start_id from {TARGET_SCHEMA_TO_LINK}._max_ids 
	WHERE lower(tbl_name) = 'max_of_all'
), cte6 as (
	SELECT cte0.start_id + t1.id as measurement_id,
		t1.person_id,
		t1.concept_id as measurement_concept_id,
		t1.start_date as measurement_date,
		t1.start_date as measurement_datetime,
		NULL as measurement_time,
		t1.type_concept_id as measurement_type_concept_id,
		t1.operator_concept_id,
		t1.value_as_number,
		t1.value_as_concept_id,
		CASE
			WHEN t1.unit_source_value is not null THEN COALESCE(t2.target_concept_id, 0)
		END as unit_concept_id,    
		t1.range_low,
		t1.range_high,
		t1.provider_id,
		t1.visit_occurrence_id,
		t1.visit_detail_id,
		t1.source_value as measurement_source_value,
		t1.source_concept_id as measurement_source_concept_id,	
		t1.unit_source_value, 
		CASE
			WHEN t1.unit_source_value is not null THEN COALESCE(t2.source_concept_id, 0)
		END as unit_source_concept_id,
		CASE 
			WHEN t1.value_source_value <> t1.source_value THEN t1.value_source_value
		END AS value_source_value,
		t1.measurement_event_id as measurement_event_id,
		t1.meas_event_field_concept_id as meas_event_field_concept_id
	from cte0, {CHUNK_SCHEMA}.stem_{CHUNK_ID} t1
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_vocabulary_id = 'UCUM' 
	and t2.source_code = t1.unit_source_value and t2.target_domain_id = 'Unit'
	where t1.domain_id = 'Measurement'
)
insert into {TARGET_SCHEMA}.measurement(measurement_id, person_id, measurement_concept_id, measurement_date,
										 measurement_datetime, measurement_time, measurement_type_concept_id,
										 operator_concept_id, value_as_number, value_as_concept_id, unit_concept_id,
										 range_low, range_high, provider_id, visit_occurrence_id, visit_detail_id,
										 measurement_source_value, measurement_source_concept_id, unit_source_value,
										 unit_source_concept_id, value_source_value, measurement_event_id, meas_event_field_concept_id)
select * FROM cte6;

--------------------------------
--insert into specimen from stem
--------------------------------
with cte0 AS (
	SELECT max_id  + 1 as start_id from {TARGET_SCHEMA_TO_LINK}._max_ids 
	WHERE lower(tbl_name) = 'max_of_all'
), cte7 as (
	SELECT cte0.start_id + id as specimen_id,
		person_id,
		concept_id as specimen_concept_id,
		type_concept_id as specimen_type_concept_id,
		start_date as specimen_date,
		start_date as specimen_datetime,
		quantity,
		unit_concept_id,		
		NULL::int as anatomic_site_concept_id,
		NULL::int as disease_status_concept_id,
		specimen_source_id,
		source_value as specimen_source_value,
		unit_source_value,
		NULL as anatomic_site_source_value,
		NULL as disease_status_source_value
	from cte0, {CHUNK_SCHEMA}.stem_{CHUNK_ID}
	where domain_id = 'Specimen'
)
insert into {TARGET_SCHEMA}.specimen(specimen_id, person_id, specimen_concept_id, specimen_type_concept_id, 
									specimen_date, specimen_datetime, quantity, unit_concept_id, anatomic_site_concept_id, 
									disease_status_concept_id, specimen_source_id, specimen_source_value, unit_source_value, 
									anatomic_site_source_value, disease_status_source_value)
select * FROM cte7;

--------------------------------
--insert into episode from stem
--------------------------------
with cte0 AS (
	SELECT max_id  + 1 as start_id from {TARGET_SCHEMA_TO_LINK}._max_ids 
	WHERE lower(tbl_name) = 'max_of_all'
), cte8 as (
	SELECT cte0.start_id + id as episode_id,
		person_id,
		concept_id as episode_concept_id,
		start_date as episode_start_date,
		start_date as episode_start_datetime,
		end_date as episode_end_date,
		end_date as episode_end_datetime,
		source_concept_id as episode_parent_id,
		value_as_number as episode_number,
		value_as_concept_id as episode_object_concept_id,
		type_concept_id as episode_type_concept_id,
		source_value as episode_source_value,
		CASE 
			WHEN source_value is not null THEN 0
		END as episode_source_concept_id
	from cte0, {CHUNK_SCHEMA}.stem_{CHUNK_ID}
	where domain_id = 'Episode'
)
insert into {TARGET_SCHEMA}.episode(episode_id, person_id, episode_concept_id, episode_start_date, episode_start_datetime, 
								episode_end_date, episode_end_datetime, episode_parent_id, episode_number, 
								episode_object_concept_id, episode_type_concept_id, episode_source_value, 
								episode_source_concept_id)
select * FROM cte8;

-----------------------------------------
-- EPISODE_EVENT
-----------------------------------------
-- Disease Episode
with cte0 AS (
	SELECT max_id  + 1 as start_id from {TARGET_SCHEMA_TO_LINK}._max_ids 
	WHERE lower(tbl_name) = 'max_of_all'
), cte1 as(
	select 
		cte0.start_id + id as episode_id,
		person_id,
		stem_source_id
	from cte0, {CHUNK_SCHEMA}.stem_{CHUNK_ID}
	where concept_id = 32533  -- Disease Episode
)
insert into {TARGET_SCHEMA}.episode_event
select 
	t2.episode_id,
	cte0.start_id + t1.id as event_id, 
	CASE 
		WHEN t1.domain_id = 'Condition' THEN 1147127
		WHEN t1.domain_id = 'Measurement' THEN 1147138
		WHEN t1.domain_id = 'Observation' THEN 1147165
		WHEN t1.domain_id = 'Procedure' THEN 1147082	
		WHEN t1.domain_id = 'Drug' THEN 1147094		
		WHEN t1.domain_id = 'Specimen' THEN 1147049
		WHEN t1.domain_id = 'Device' THEN 1147115
		ELSE 1147165
	END as event_field_concept_id
from cte0, {CHUNK_SCHEMA}.stem_{CHUNK_ID} as t1
join cte1 as t2 on t1.stem_source_id = t2.stem_source_id and t1.person_id = t2.person_id
where t1.stem_source_table like 'Tumour%'
and t1.domain_id <> 'Episode';

-- Treatment Regimen Episode
with cte0 AS (
	SELECT max_id  + 1 as start_id from {TARGET_SCHEMA_TO_LINK}._max_ids 
	WHERE lower(tbl_name) = 'max_of_all'
), cte1 as(
	select 
		cte0.start_id + id as episode_id,
		person_id,
		stem_source_id --treatment_id
	from cte0, {CHUNK_SCHEMA}.stem_{CHUNK_ID}
	where concept_id = 32531  -- Treatment Regimen Episode
)
insert into {TARGET_SCHEMA}.episode_event
select   
		t2.episode_id, --episode_id
		cte0.start_id + t1.id as event_id,
		CASE 
			WHEN t1.domain_id = 'Condition' THEN 1147127
			WHEN t1.domain_id = 'Measurement' THEN 1147138
			WHEN t1.domain_id = 'Observation' THEN 1147165
			WHEN t1.domain_id = 'Procedure' THEN 1147082	
			WHEN t1.domain_id = 'Drug' THEN 1147094		
			WHEN t1.domain_id = 'Specimen' THEN 1147049
			WHEN t1.domain_id = 'Device' THEN 1147115
			ELSE 1147165
		END as event_field_concept_id
from cte0, {CHUNK_SCHEMA}.stem_{CHUNK_ID} as t1
join cte1 as t2 on t2.stem_source_id = t1.stem_source_id  --treatment_id
where t1.stem_source_table like 'Treatment%'
and t1.domain_id <> 'Episode';

--------------------------------
--insert into observation from stem.
--------------------------------
with cte0 AS (
	SELECT max_id  + 1 as start_id from {TARGET_SCHEMA_TO_LINK}._max_ids 
	WHERE lower(tbl_name) = 'max_of_all'
), cte11 as (
	SELECT cte0.start_id + id as observation_id,
		t1.person_id,
		t1.concept_id as observation_concept_id,
		t1.start_date as observation_date,
		t1.start_date as observation_datetime,
		t1.type_concept_id as observation_type_concept_id,
		t1.value_as_number,
		t1.value_as_string,	
		t1.value_as_concept_id,
		t1.qualifier_concept_id,
		CASE 
			WHEN t1.unit_source_value is NULL THEN NULL
			ELSE COALESCE(t2.target_concept_id, 0)
		END as unit_concept_id,	
		t1.provider_id,
		t1.visit_occurrence_id,
		t1.visit_detail_id,
		t1.source_value as observation_source_value,
		t1.source_concept_id as observation_source_concept_id,
		t1.unit_source_value,
		t1.qualifier_source_value,
		CASE 
			WHEN t1.value_source_value <> t1.source_value THEN t1.value_source_value
		END as value_source_value,
		t1.observation_event_id,
		t1.obs_event_field_concept_id
	from cte0, {CHUNK_SCHEMA}.stem_{CHUNK_ID} as t1
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_vocabulary_id = 'UCUM' 
	and t2.source_code = LEFT(t1.unit_source_value, 2) and t2.target_domain_id = 'Unit'
	where t1.domain_id not in ('Condition', 'Procedure', 'Drug', 'Measurement', 'Device', 'Specimen', 'Episode')
)
insert into {TARGET_SCHEMA}.observation (observation_id, person_id, observation_concept_id, observation_date,
										  observation_datetime, observation_type_concept_id, value_as_number, value_as_string,
										  value_as_concept_id, qualifier_concept_id, unit_concept_id, provider_id,
										  visit_occurrence_id, visit_detail_id, observation_source_value,
										  observation_source_concept_id, unit_source_value, qualifier_source_value,
										  value_source_value, observation_event_id, obs_event_field_concept_id)
select * from cte11;
-----------------------------------------
-- UPDATE CHUNK
-----------------------------------------
update {CHUNK_SCHEMA}.chunk 
set 
completed = 1
where chunk_id = {CHUNK_ID};