--------------------------------
-- insert into condition_occurrence from stem_{CHUNK_ID}
--------------------------------
with cte0 AS (
	SELECT COALESCE(max_id, 0) as start_id from {TARGET_SCHEMA_TO_LINK}._max_ids 
	WHERE lower(tbl_name) = 'condition_occurrence'
),
cte1 as (
	SELECT cte0.start_id + s.id as condition_occurrence_id,
		s.person_id,
		s.concept_id as condition_concept_id,
		case when s.start_date is NULL
		 then v.visit_start_date
		else s.start_date end as condition_start_date,
		case when s.start_date is NULL
		 then v.visit_start_date
		else s.start_date end::TIMESTAMP as condition_start_datetime,
		s.end_date as condition_end_date,
		s.end_date::TIMESTAMP as condition_end_datetime,
		s.type_concept_id as condition_type_concept_id,
		s.disease_status_concept_id as condition_status_concept_id,
		s.stop_reason,
		s.provider_id,
		s.visit_occurrence_id,
		s.visit_detail_id,
		s.source_value as condition_source_value,
		s.source_concept_id as condition_source_concept_id,
		s.disease_status_source_value as condition_status_source_value
	from cte0, {CHUNK_SCHEMA}.stem_{CHUNK_ID} s
	inner join {TARGET_SCHEMA}.visit_occurrence v on s.visit_occurrence_id = v.visit_occurrence_id
	where s.domain_id = 'Condition'
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
	SELECT COALESCE(max_id, 0) as start_id from {TARGET_SCHEMA_TO_LINK}._max_ids 
	WHERE lower(tbl_name) = 'drug_exposure'
),
cte2 as (
	SELECT cte0.start_id + s.id as drug_exposure_id,
		s.person_id,
		s.concept_id as drug_concept_id,
		case when s.start_date is NULL
			then v.visit_start_date
		else s.start_date end as drug_exposure_start_date,
		case when s.start_date is NULL
			then v.visit_start_date
		else s.start_date end::TIMESTAMP as drug_exposure_start_datetime,
		case when s.end_date is NULL
			then v.visit_start_date
		else s.end_date end as drug_exposure_end_date,
		case when s.end_date is NULL
			then v.visit_start_date
		else s.end_date end::TIMESTAMP as drug_exposure_end_datetime,
		NULL::date as verbatim_end_date,
		s.type_concept_id as drug_type_concept_id,
		s.stop_reason,
		s.refills,
		s.quantity,
		s.days_supply,
		s.sig,
		s.route_concept_id,
		s.lot_number,
		s.provider_id,
		s.visit_occurrence_id,
		s.visit_detail_id,
		s.source_value as drug_source_value,
		s.source_concept_id as drug_source_concept_id,
		s.route_source_value,
		s.dose_unit_source_value
from cte0, {CHUNK_SCHEMA}.stem_{CHUNK_ID} s
inner join {TARGET_SCHEMA}.visit_occurrence v on s.visit_occurrence_id = v.visit_occurrence_id
where s.domain_id = 'Drug'
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
	SELECT COALESCE(max_id, 0) as start_id from {TARGET_SCHEMA_TO_LINK}._max_ids 
	WHERE lower(tbl_name) = 'device_exposure'
),
cte4 as (
	SELECT cte0.start_id + s.id as device_exposure_id,
		s.person_id,
		s.concept_id as device_concept_id,
		case when s.start_date is NULL
			then v.visit_start_date
		else s.start_date end as device_exposure_start_date,
		case when s.start_date is NULL
			then v.visit_start_date
		else s.start_date end::TIMESTAMP as device_exposure_start_datetime,
		s.end_date as device_exposure_end_date,
		s.end_date as device_exposure_end_datetime,
		s.type_concept_id as device_type_concept_id,
		s.unique_device_id,
		s.quantity,
		s.provider_id,
		s.visit_occurrence_id,
		s.visit_detail_id,
		s.source_value as device_source_value,
		s.source_concept_id as device_source_concept_id
	from cte0, {CHUNK_SCHEMA}.stem_{CHUNK_ID} s
	inner join {TARGET_SCHEMA}.visit_occurrence v on s.visit_occurrence_id = v.visit_occurrence_id
	where s.domain_id = 'Device'
)

insert into {TARGET_SCHEMA}.device_exposure(device_exposure_id, person_id, device_concept_id, device_exposure_start_date,
											 device_exposure_start_datetime, device_exposure_end_date, device_exposure_end_datetime,
											 device_type_concept_id, unique_device_id, quantity, provider_id, visit_occurrence_id,
											 visit_detail_id, device_source_value, device_source_concept_id)
select * from cte4;


--------------------------------
--insert into procedure_occurrence from stem
--------------------------------
with cte0 AS (
	SELECT COALESCE(max_id, 0) as start_id from {TARGET_SCHEMA_TO_LINK}._max_ids 
	WHERE lower(tbl_name) = 'procedure_occurrence'
),
cte5 as (
	SELECT cte0.start_id + s.id as procedure_occurrence_id,
		s.person_id,
		s.concept_id as procedure_concept_id,
		case when s.start_date is NULL
			then v.visit_start_date
		else s.start_date end as procedure_date,
		case when s.start_date is NULL
			then v.visit_start_date
		else s.start_date end::TIMESTAMP as procedure_datetime,
		case when s.start_date is NULL
			then v.visit_start_date
		else s.start_date end as procedure_end_date,
		case when s.start_date is NULL
			then v.visit_start_date
		else s.start_date end::TIMESTAMP as procedure_end_datetime,
		s.type_concept_id as procedure_type_concept_id,
		s.modifier_concept_id,
		s.quantity,
		s.provider_id,
		s.visit_occurrence_id,
		s.visit_detail_id,
		s.source_value as procedure_source_value,
		s.source_concept_id as procedure_source_concept_id,
		s.modifier_source_value
	from cte0, {CHUNK_SCHEMA}.stem_{CHUNK_ID} s
	inner join {TARGET_SCHEMA}.visit_occurrence v on s.visit_occurrence_id = v.visit_occurrence_id
	where s.domain_id = 'Procedure'
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
	SELECT COALESCE(max_id, 0) as start_id from {TARGET_SCHEMA_TO_LINK}._max_ids 
	WHERE lower(tbl_name) = 'measurement'
), cte6 as (
	SELECT cte0.start_id + s.id as measurement_id,
		s.person_id,
		s.concept_id as measurement_concept_id,
		case when s.start_date is NULL
			then v.visit_start_date
		else s.start_date end as measurement_date,
		case when s.start_date is NULL
			then v.visit_start_date
		else s.start_date end::TIMESTAMP as measurement_datetime,
		NULL as measurement_time,
		s.type_concept_id as measurement_type_concept_id,
		s.operator_concept_id,
		s.value_as_number,
		s.value_as_concept_id,
		case when stsvm.target_concept_id is NULL
			then 0
			else stsvm.target_concept_id end as unit_concept_id,
		s.range_low,
		s.range_high,
		s.provider_id,
		s.visit_occurrence_id,
		s.visit_detail_id,
		s.source_value as measurement_source_value,
		s.source_concept_id as measurement_source_concept_id,
		s.unit_source_value,
		s.value_source_value
	from cte0, {CHUNK_SCHEMA}.stem_{CHUNK_ID} s
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map stsvm
		on s.unit_source_value = stsvm.source_code
		and stsvm.source_vocabulary_id = 'UCUM'
	inner join {TARGET_SCHEMA}.visit_occurrence v on s.visit_occurrence_id = v.visit_occurrence_id
	where s.domain_id = 'Measurement'
)

insert into {TARGET_SCHEMA}.measurement(measurement_id, person_id, measurement_concept_id, measurement_date,
										 measurement_datetime, measurement_time, measurement_type_concept_id,
										 operator_concept_id, value_as_number, value_as_concept_id, unit_concept_id,
										 range_low, range_high, provider_id, visit_occurrence_id, visit_detail_id,
										 measurement_source_value, measurement_source_concept_id, unit_source_value,
										 value_source_value)
select * FROM cte6;

--------------------------------
--insert into observation from stem. To increase performance, could we change the "not in" into "in" ?
--------------------------------
with cte0 AS (
	SELECT COALESCE(max_id, 0) as start_id from {TARGET_SCHEMA_TO_LINK}._max_ids 
	WHERE lower(tbl_name) = 'observation'
), cte7 as (
	SELECT cte0.start_id + s.id as observation_id,
		s.person_id,
		s.concept_id as observation_concept_id,
		case when s.start_date is NULL
			then v.visit_start_date
		else s.start_date end as observation_date,
		case when s.start_date is NULL
			then v.visit_start_date
		else s.start_date end::TIMESTAMP as observation_datetime,
		s.type_concept_id as observation_type_concept_id,
		s.value_as_number,
		s.value_as_string,
		s.value_as_concept_id,
		s.qualifier_concept_id,
		case when stsvm.target_concept_id is NULL
			then 0
			else stsvm.target_concept_id end as unit_concept_id,
		s.provider_id,
		s.visit_occurrence_id,
		s.visit_detail_id,
		s.source_value as observation_source_value,
		s.source_concept_id as observation_source_concept_id,
		s.unit_source_value,
		s.qualifier_source_value
	from cte0, {CHUNK_SCHEMA}.stem_{CHUNK_ID} s
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map stsvm
		on s.unit_source_value = stsvm.source_code
		and stsvm.source_vocabulary_id = 'UCUM'
	inner join {TARGET_SCHEMA}.visit_occurrence v on s.visit_occurrence_id = v.visit_occurrence_id
	where s.domain_id not in ('Condition', 'Procedure', 'Measurement', 'Drug', 'Device')
)
insert into {TARGET_SCHEMA}.observation (observation_id, person_id, observation_concept_id, observation_date,
										  observation_datetime, observation_type_concept_id, value_as_number, value_as_string,
										  value_as_concept_id, qualifier_concept_id, unit_concept_id, provider_id,
										  visit_occurrence_id, visit_detail_id, observation_source_value,
										  observation_source_concept_id, unit_source_value, qualifier_source_value)
select * from cte7;

-----------------------------------------
-- UPDATE CHUNK
-----------------------------------------
update {CHUNK_SCHEMA}.chunk 
set 
completed = 1
where chunk_id = {CHUNK_ID};