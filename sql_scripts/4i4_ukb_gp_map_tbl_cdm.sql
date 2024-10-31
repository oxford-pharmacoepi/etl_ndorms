--------------------------------
--insert into drug_exposure from stem
--------------------------------
insert into {TARGET_SCHEMA}.drug_exposure										
SELECT 	
		t1.id as drug_exposure_id,
		t1.person_id,
		t1.concept_id as drug_concept_id,
		t1.start_date as drug_exposure_start_date,
		t1.start_date as drug_exposure_start_datetime,
		t1.end_date as drug_exposure_end_date,
		t1.end_date as drug_exposure_end_datetime,
		NULL::date as verbatim_end_date,
		t1.type_concept_id as drug_type_concept_id,
		t1.stop_reason,
		t1.refills,
		t1.quantity,
		t1.days_supply,
		t1.sig,														-- keep the source data for reference
		t1.route_concept_id,
		t1.lot_number,
		t1.provider_id,
		t1.visit_occurrence_id,
		t1.visit_detail_id,
		t1.source_value as drug_source_value,
		t1.source_concept_id as drug_source_concept_id,
		t1.route_source_value,
		t1.dose_unit_source_value
from {CHUNK_SCHEMA}.stem_{CHUNK_ID} as t1
where t1.domain_id = 'Drug';

--------------------------------
--insert into device_exposure from stem
--------------------------------
insert into {TARGET_SCHEMA}.device_exposure
SELECT 
		t1.id as device_exposure_id,
		t1.person_id,
		t1.concept_id as device_concept_id,
		t1.start_date as device_exposure_start_date,
		t1.start_date as device_exposure_start_datetime,
		t1.end_date as device_exposure_end_date,
		t1.end_date as device_exposure_end_datetime,
		t1.type_concept_id as device_type_concept_id,
		t1.unique_device_id,
		NULL as production_id,
		CASE 
			WHEN t1.quantity = 0 THEN 1
			ELSE COALESCE(t1.quantity, 1)
		END AS quantity,
		t1.provider_id,
		t1.visit_occurrence_id,
		t1.visit_detail_id,
		t1.source_value as device_source_value,
		t1.source_concept_id as device_source_concept_id,
		CASE
			WHEN t1.unit_source_value is not null THEN COALESCE(t2.target_concept_id, 0)
		END as unit_concept_id,  
		t1.unit_source_value, 
		CASE
			WHEN t1.unit_source_value is not null THEN COALESCE(t2.source_concept_id, 0)
		END as unit_source_concept_id
from {CHUNK_SCHEMA}.stem_{CHUNK_ID} as t1
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_vocabulary_id = 'UKB_GP_DEVICE_UNIT_STCM' 
and (regexp_match(trim(unit_source_value), '^[-]\d+|^[-]\s\d+|^[*]\d+|^\d'))[1] is NULL
and t2.source_code = lower((regexp_match(t1.unit_source_value, '[a-zA-Z]+'))[1])
where t1.domain_id = 'Device';

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
		t1.id as measurement_id,
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
		t2.source_code as unit_source_value, 
		CASE
			WHEN t1.unit_source_value is not null THEN COALESCE(t2.source_concept_id, 0)
		END as unit_source_concept_id,
		t1.value_source_value,
		t1.measurement_event_id as measurement_event_id,
		t1.meas_event_field_concept_id as meas_event_field_concept_id
from {CHUNK_SCHEMA}.stem_{CHUNK_ID} as t1
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_vocabulary_id = 'UKB_GP_CLINICAL_UNIT_STCM' 
and t2.source_code = t1.unit_source_value
where t1.domain_id = 'Measurement';

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
--insert into observation from stem.
--------------------------------
insert into {TARGET_SCHEMA}.observation 
SELECT 
		t1.id as observation_id,
		t1.person_id,
		t1.concept_id as observation_concept_id,
		t1.start_date as observation_date,
		t1.start_date as observation_datetime,
		t1.type_concept_id as observation_type_concept_id,
		t1.value_as_number,
		CASE
			WHEN length(unit_source_value)>100 THEN t1.value_as_string
			WHEN lower(t1.value_as_string) = lower(t1.unit_source_value) THEN NULL
			WHEN t1.value_as_number::text = t1.unit_source_value THEN NULL
			WHEN t1.value_as_string ~ '\D[/]\S[^0-9]+|.per.' THEN NULL
			ELSE t1.value_as_string
		END AS value_as_string,	
		t1.value_as_concept_id,
		t1.qualifier_concept_id,
		COALESCE(t2.target_concept_id ,CASE WHEN t1.value_as_string ~ '\D[/]\S[^0-9]+|.per.' and length(unit_source_value)<=100 THEN 0 END) as unit_concept_id,		
		t1.provider_id,
		t1.visit_occurrence_id,
		t1.visit_detail_id,
		COALESCE(t3.concept_code, t1.source_value) as observation_source_value,
		COALESCE(t3.concept_id, t1.source_concept_id) as observation_source_concept_id,
		COALESCE(t2.source_code ,CASE WHEN t1.value_as_string ~ '\D[/]\S[^0-9]+|.per.' and length(unit_source_value)<=100 THEN t1.value_as_string END) as unit_source_value,
		t1.qualifier_source_value,
		t1.value_source_value,
		t1.observation_event_id,
		t1.obs_event_field_concept_id
from {CHUNK_SCHEMA}.stem_{CHUNK_ID} as t1
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_vocabulary_id = 'UKB_GP_CLINICAL_UNIT_STCM' 
and t2.source_code = t1.unit_source_value
left join {VOCABULARY_SCHEMA}.concept as t3 on t3.vocabulary_id = 'Read' and t1.concept_id = 0 --get the concept_id which Athena map to 0
and t3.concept_code = concat(t1.source_value, '00') 
where t1.domain_id not in ('Condition', 'Procedure', 'Drug', 'Measurement', 'Device', 'Specimen');


-----------------------------------------
-- UPDATE CHUNK
-----------------------------------------
update {CHUNK_SCHEMA}.chunk 
set 
completed = 1
where chunk_id = {CHUNK_ID};