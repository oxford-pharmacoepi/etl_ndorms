--------------------------------
-- insert into condition_occurrence from stem_{CHUNK_ID}
--------------------------------
with cte1 as (
	SELECT s.id as condition_occurrence_id,
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
		NULL::bigint as condition_status_concept_id,
		s.stop_reason,
		s.provider_id,
		s.visit_occurrence_id,
		s.visit_detail_id,
		s.source_value as condition_source_value,
		s.source_concept_id as condition_source_concept_id,
		NULL as condition_status_source_value
	from {CHUNK_SCHEMA}.stem_{CHUNK_ID} s
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
with cte2 as (
	SELECT s.id as drug_exposure_id,
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
		case when t2.target_concept_id is NULL
			then 0
			else t2.target_concept_id end as route_concept_id,
		s.lot_number,
		s.provider_id,
		s.visit_occurrence_id,
		s.visit_detail_id,
		s.source_value as drug_source_value,
		s.source_concept_id as drug_source_concept_id,
		s.route_source_value,
		s.dose_unit_source_value
from {CHUNK_SCHEMA}.stem_{CHUNK_ID} s
left join {TARGET_SCHEMA}.source_to_standard_vocab_map t2 on t2.source_code = s.route_source_value and t2.source_vocabulary_id = 'AURUM_ROUTE_STCM'
left join {TARGET_SCHEMA}.visit_occurrence v on s.visit_occurrence_id = v.visit_occurrence_id	--AD: 2023_05_18 changed JOIN to LEFT JOIN - it was always empty?????? as stem does not have visit_occurrence_ids for drugs without links to Problem. INTEGRATED WITH THE FOLLOWING, which is removed
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
with cte4 as (
	SELECT s.id as device_exposure_id,
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
	from {CHUNK_SCHEMA}.stem_{CHUNK_ID} s
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
with cte5 as (
	SELECT s.id as procedure_occurrence_id,
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
	from {CHUNK_SCHEMA}.stem_{CHUNK_ID} s
	inner join {TARGET_SCHEMA}.visit_occurrence v on s.visit_occurrence_id = v.visit_occurrence_id
	where s.domain_id = 'Procedure'
)

insert into {TARGET_SCHEMA}.procedure_occurrence(procedure_occurrence_id, person_id, procedure_concept_id, procedure_date, procedure_datetime, 
												  procedure_end_date, procedure_end_datetime, 
												  procedure_type_concept_id, modifier_concept_id, quantity,
												  provider_id, visit_occurrence_id, visit_detail_id, procedure_source_value,
												  procedure_source_concept_id, modifier_source_value)
select * from cte5;

--------------------------------
--insert into measurement from stem
--------------------------------
with cte6a as (
	SELECT distinct unit_source_value
	from {CHUNK_SCHEMA}.stem_{CHUNK_ID}
),
cte6b as (select t1.unit_source_value,
	CASE WHEN t2.target_concept_id is NOT NULL THEN t2.target_concept_id 
		 WHEN t3.target_concept_id is NOT NULL THEN t3.target_concept_id
		 ELSE 0 END AS unit_concept_id
	from cte6a as t1
	left join {TARGET_SCHEMA}.source_to_standard_vocab_map t2 on t1.unit_source_value = t2.source_code and t2.source_vocabulary_id = 'UCUM'
	left join {TARGET_SCHEMA}.source_to_standard_vocab_map t3 on t2.target_concept_id is NULL AND t1.unit_source_value = t3.source_code
		and t3.source_vocabulary_id = 'AURUM_UNIT_STCM'
),
cte6 as	(
	SELECT s.id as measurement_id,
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
		t2.unit_concept_id,
		s.range_low,
		s.range_high,
		s.provider_id,
		s.visit_occurrence_id,
		s.visit_detail_id,
		s.source_value as measurement_source_value,
		s.source_concept_id as measurement_source_concept_id,
		s.unit_source_value,
		s.value_source_value
	from {CHUNK_SCHEMA}.stem_{CHUNK_ID} s
	left join cte6b as t2 on s.unit_source_value = t2.unit_source_value
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
--insert into observation from stem.
--------------------------------
with cte7a as (
	SELECT distinct unit_source_value
	from {CHUNK_SCHEMA}.stem_{CHUNK_ID}
),
cte7b as (select t1.unit_source_value,
	CASE WHEN t2.target_concept_id is NOT NULL THEN t2.target_concept_id 
		 WHEN t3.target_concept_id is NOT NULL THEN t3.target_concept_id
		 ELSE 0 END AS unit_concept_id
	from cte7a as t1
	left join {TARGET_SCHEMA}.source_to_standard_vocab_map t2 on t1.unit_source_value = t2.source_code and t2.source_vocabulary_id = 'UCUM'
	left join {TARGET_SCHEMA}.source_to_standard_vocab_map t3 on t2.target_concept_id is NULL AND t1.unit_source_value = t3.source_code
		and t3.source_vocabulary_id = 'AURUM_UNIT_STCM'
),
cte7 as (
	SELECT s.id as observation_id,
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
		t3.unit_concept_id,
		s.provider_id,
		s.visit_occurrence_id,
		s.visit_detail_id,
		s.source_value as observation_source_value,
		s.source_concept_id as observation_source_concept_id,
		s.unit_source_value,
		s.qualifier_source_value
	from {CHUNK_SCHEMA}.stem_{CHUNK_ID} s
	left join (values('Condition', 'Procedure', 'Measurement', 'Drug', 'Device')) as t2(domain_id) on t2.domain_id = s.domain_id
	left join cte7b as t3 on s.unit_source_value = t3.unit_source_value
	inner join {TARGET_SCHEMA}.visit_occurrence v on s.visit_occurrence_id = v.visit_occurrence_id
--	where s.domain_id not in ('Condition', 'Procedure', 'Measurement', 'Drug', 'Device')
	where t2.domain_id is null
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