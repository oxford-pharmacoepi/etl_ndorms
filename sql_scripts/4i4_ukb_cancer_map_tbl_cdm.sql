--------------------------------
--insert into drug_exposure from stem
--------------------------------
insert into {TARGET_SCHEMA}.drug_exposure										
SELECT 	
		id as drug_exposure_id,
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
from {CHUNK_SCHEMA}.stem_{CHUNK_ID}
where domain_id = 'Drug';

--------------------------------
--insert into device_exposure from stem
--------------------------------
insert into {TARGET_SCHEMA}.device_exposure
SELECT 
		id as device_exposure_id,
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
from {CHUNK_SCHEMA}.stem_{CHUNK_ID}
where domain_id = 'Device';

--------------------------------
-- insert into condition_occurrence from stem
--------------------------------
insert into {TARGET_SCHEMA}.condition_occurrence
SELECT 
		id as condition_occurrence_id,
		person_id,
		concept_id as condition_concept_id,
		start_date as condition_start_date,
		start_date as condition_start_datetime,
		end_date as condition_end_date,
		end_date as condition_end_datetime,
		type_concept_id as condition_type_concept_id,
		NULL as condition_status_concept_id, 
		stop_reason,
		provider_id,
		visit_occurrence_id,
		visit_detail_id,
		source_value as condition_source_value,
		source_concept_id as condition_source_concept_id,
		NULL as condition_status_source_value
from {CHUNK_SCHEMA}.stem_{CHUNK_ID}
where domain_id = 'Condition';

--------------------------------
--insert into procedure_occurrence from stem
--------------------------------
insert into {TARGET_SCHEMA}.procedure_occurrence
SELECT 
		id as procedure_occurrence_id,
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
from {CHUNK_SCHEMA}.stem_{CHUNK_ID}
where domain_id = 'Procedure';

--------------------------------
--insert into measurement from stem
--------------------------------
insert into {TARGET_SCHEMA}.measurement
SELECT 
		id as measurement_id,
		person_id,
		concept_id as measurement_concept_id,
		start_date as measurement_date,
		start_date as measurement_datetime,
		NULL as measurement_time,
		type_concept_id as measurement_type_concept_id,
		operator_concept_id,
		value_as_number,
		value_as_concept_id,
		unit_concept_id,  
		range_low,
		range_high,
		provider_id,
		visit_occurrence_id,
		visit_detail_id,
		source_value as measurement_source_value,
		source_concept_id as measurement_source_concept_id,	
		unit_source_value, 
		unit_source_concept_id,
		value_source_value,
		measurement_event_id as measurement_event_id,
		meas_event_field_concept_id as meas_event_field_concept_id
from {CHUNK_SCHEMA}.stem_{CHUNK_ID} as t1
where domain_id = 'Measurement';

--------------------------------
--insert into specimen from stem
--------------------------------
insert into {TARGET_SCHEMA}.specimen 
SELECT 
		id as specimen_id,
		person_id,
		concept_id as specimen_concept_id,
		type_concept_id as specimen_type_concept_id,
		start_date as specimen_date,
		start_date as specimen_datetime,
		quantity,
		unit_concept_id,		
		NULL as anatomic_site_concept_id,
		NULL as disease_status_concept_id,
		specimen_source_id,
		source_value as specimen_source_value,
		unit_source_value,
		NULL as anatomic_site_source_value,
		NULL as disease_status_source_value
from {CHUNK_SCHEMA}.stem_{CHUNK_ID}
where domain_id = 'Specimen';

--------------------------------
--insert into episode from stem
--------------------------------
insert into {TARGET_SCHEMA}.episode 
SELECT 	
		id as episode_id,
		person_id,
		concept_id as episode_concept_id,
		start_date as episode_start_date,
		start_date as episode_start_datetime,
		end_date as episode_end_date,
		end_date as episode_end_datetime,
		NULL as episode_parent_id,
		value_as_number as episode_number,
		value_as_concept_id as episode_object_concept_id,
		type_concept_id as episode_type_concept_id,
		source_value as episode_source_value,
		source_concept_id as episode_source_concept_id
from {CHUNK_SCHEMA}.stem_{CHUNK_ID}
where domain_id = 'Episode';

-----------------------------------------
-- EPISODE_EVENT
-----------------------------------------
-- Disease Episode
With cte0 as(
	select 
		id as episode_id,
		person_id,
		stem_source_id
	from {CHUNK_SCHEMA}.stem_{CHUNK_ID}
	where concept_id = 32533  -- Disease Episode
)
insert into {TARGET_SCHEMA}.episode_event
select 
	t2.episode_id,
	t1.id as event_id, 
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
from {CHUNK_SCHEMA}.stem_{CHUNK_ID} as t1
join cte0 as t2 on t1.stem_source_id = t2.stem_source_id
where t1.domain_id <> 'Episode';

--------------------------------
--insert into observation from stem.
--------------------------------
insert into {TARGET_SCHEMA}.observation 
SELECT 
		id as observation_id,
		person_id,
		concept_id as observation_concept_id,
		start_date as observation_date,
		start_date as observation_datetime,
		type_concept_id as observation_type_concept_id,
		value_as_number,
		value_as_string,	
		value_as_concept_id,
		qualifier_concept_id,
		unit_concept_id,		
		provider_id,
		visit_occurrence_id,
		visit_detail_id,
		source_value as observation_source_value,
		source_concept_id as observation_source_concept_id,
		unit_source_value,
		qualifier_source_value,
		value_source_value,
		observation_event_id,
		obs_event_field_concept_id
from {CHUNK_SCHEMA}.stem_{CHUNK_ID} as t1
where domain_id not in ('Condition', 'Procedure', 'Drug', 'Measurement', 'Device', 'Specimen', 'Episode');

-----------------------------------------
-- UPDATE CHUNK
-----------------------------------------
update {CHUNK_SCHEMA}.chunk 
set 
completed = 1
where chunk_id = {CHUNK_ID};