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
		0 as condition_status_concept_id,
		s.stop_reason,
		s.provider_id,
		s.visit_occurrence_id,
		s.visit_detail_id,
		s.source_value as condition_source_value,
		s.source_concept_id as condition_source_concept_id,
		NULL as condition_status_source_value
	from chunks.stem_{CHUNK_ID} s
	join {TARGET_SCHEMA}.visit_occurrence v on s.visit_occurrence_id = v.visit_occurrence_id
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
		s.route_concept_id,
		s.lot_number,
		s.provider_id,
		s.visit_occurrence_id,
		s.visit_detail_id,
		s.source_value as drug_source_value,
		s.source_concept_id as drug_source_concept_id,
		s.route_source_value,
		s.dose_unit_source_value
from chunks.stem_{CHUNK_ID} s
left join {TARGET_SCHEMA}.visit_occurrence v on s.visit_occurrence_id = v.visit_occurrence_id	--AD: 2023_05_18 changed JOIN to LEFT JOIN - it was always empty?????? as stem does not have visit_occurrence_ids for drugs without links to Problem. INTEGRATED WITH THE FOLLOWING, which is removed
where s.domain_id = 'Drug'
)
insert into {TARGET_SCHEMA}.drug_exposure(drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date,
											drug_exposure_start_datetime, drug_exposure_end_date, drug_exposure_end_datetime,
											verbatim_end_date, drug_type_concept_id, stop_reason, refills, quantity, days_supply,
											sig, route_concept_id, lot_number, provider_id, visit_occurrence_id, visit_detail_id,
											drug_source_value, drug_source_concept_id, route_source_value, dose_unit_source_value)
select * from cte2;

--AD: INTEGRATED IN PREVIOUS QUERY--insert vaccinations that don't have a visit_occurrence_id
--AD: INTEGRATED IN PREVIOUS QUERYwith cte3 as (
--AD: INTEGRATED IN PREVIOUS QUERY	SELECT s.id as drug_exposure_id,
--AD: INTEGRATED IN PREVIOUS QUERY		s.person_id,
--AD: INTEGRATED IN PREVIOUS QUERY		s.concept_id as drug_concept_id,
--AD: INTEGRATED IN PREVIOUS QUERY		s.start_date as drug_exposure_start_date,
--AD: INTEGRATED IN PREVIOUS QUERY		s.start_date::TIMESTAMP as drug_exposure_start_datetime,
--AD: INTEGRATED IN PREVIOUS QUERY		s.end_date as drug_exposure_end_date,
--AD: INTEGRATED IN PREVIOUS QUERY		s.end_date::TIMESTAMP as drug_exposure_end_datetime,
--AD: INTEGRATED IN PREVIOUS QUERY		NULL::date as verbatim_end_date,
--AD: INTEGRATED IN PREVIOUS QUERY		s.type_concept_id as drug_type_concept_id,
--AD: INTEGRATED IN PREVIOUS QUERY		s.stop_reason,
--AD: INTEGRATED IN PREVIOUS QUERY		s.refills,
--AD: INTEGRATED IN PREVIOUS QUERY		s.quantity,
--AD: INTEGRATED IN PREVIOUS QUERY		s.days_supply,
--AD: INTEGRATED IN PREVIOUS QUERY		s.sig,
--AD: INTEGRATED IN PREVIOUS QUERY		s.route_concept_id,
--AD: INTEGRATED IN PREVIOUS QUERY		s.lot_number,
--AD: INTEGRATED IN PREVIOUS QUERY		s.provider_id,
--AD: INTEGRATED IN PREVIOUS QUERY		s.visit_occurrence_id,
--AD: INTEGRATED IN PREVIOUS QUERY		s.visit_detail_id,
--AD: INTEGRATED IN PREVIOUS QUERY		s.source_value as drug_source_value,
--AD: INTEGRATED IN PREVIOUS QUERY		s.source_concept_id as drug_source_concept_id,
--AD: INTEGRATED IN PREVIOUS QUERY		s.route_source_value,
--AD: INTEGRATED IN PREVIOUS QUERY		s.dose_unit_source_value
--AD: INTEGRATED IN PREVIOUS QUERY	from chunks.stem_{CHUNK_ID} s
--AD: INTEGRATED IN PREVIOUS QUERY	where s.source_concept_id in (
--AD: INTEGRATED IN PREVIOUS QUERY		35891522,--AstraZeneca vaccine
--AD: INTEGRATED IN PREVIOUS QUERY		35891709,--Pfizer vaccine
--AD: INTEGRATED IN PREVIOUS QUERY		35896177,--Jansen vaccine
--AD: INTEGRATED IN PREVIOUS QUERY		36122814,--Novavax Baxter vaccine
--AD: INTEGRATED IN PREVIOUS QUERY		35895095,--Spikevax Moderna vaccine
--AD: INTEGRATED IN PREVIOUS QUERY		36122820,--Valneva vaccine
--AD: INTEGRATED IN PREVIOUS QUERY		36122811 --Medicago vaccine
--AD: INTEGRATED IN PREVIOUS QUERY	)
--AD: INTEGRATED IN PREVIOUS QUERY	and s.domain_id = 'Drug'
--AD: INTEGRATED IN PREVIOUS QUERY	and s.visit_occurrence_id is null
--AD: INTEGRATED IN PREVIOUS QUERY)
--AD: INTEGRATED IN PREVIOUS QUERYinsert into {TARGET_SCHEMA}.drug_exposure(drug_exposure_id, person_id, drug_concept_id, drug_exposure_start_date,
--AD: INTEGRATED IN PREVIOUS QUERY											drug_exposure_start_datetime, drug_exposure_end_date, drug_exposure_end_datetime,
--AD: INTEGRATED IN PREVIOUS QUERY											verbatim_end_date, drug_type_concept_id, stop_reason, refills, quantity, days_supply,
--AD: INTEGRATED IN PREVIOUS QUERY											sig, route_concept_id, lot_number, provider_id, visit_occurrence_id, visit_detail_id,
--AD: INTEGRATED IN PREVIOUS QUERY											drug_source_value, drug_source_concept_id, route_source_value, dose_unit_source_value)
--AD: INTEGRATED IN PREVIOUS QUERYselect * from cte3;

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
	from chunks.stem_{CHUNK_ID} s
	join {TARGET_SCHEMA}.visit_occurrence v on s.visit_occurrence_id = v.visit_occurrence_id
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
	from chunks.stem_{CHUNK_ID} s
	join {TARGET_SCHEMA}.visit_occurrence v on s.visit_occurrence_id = v.visit_occurrence_id
	where s.domain_id = 'Procedure'
)

insert into {TARGET_SCHEMA}.procedure_occurrence(procedure_occurrence_id, person_id, procedure_concept_id, procedure_date,
												  procedure_datetime, procedure_type_concept_id, modifier_concept_id, quantity,
												  provider_id, visit_occurrence_id, visit_detail_id, procedure_source_value,
												  procedure_source_concept_id, modifier_source_value)
select * from cte5;

--------------------------------
--insert into measurement from stem
--------------------------------
with cte6 as (
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
	from chunks.stem_{CHUNK_ID} s
	left join {TARGET_SCHEMA}.source_to_standard_vocab_map stsvm
		on s.unit_source_value = stsvm.source_code
		and stsvm.source_vocabulary_id = 'UCUM'
	join {TARGET_SCHEMA}.visit_occurrence v
		on s.visit_occurrence_id = v.visit_occurrence_id
	where s.domain_id = 'Measurement'
)

insert into {TARGET_SCHEMA}.measurement(measurement_id, person_id, measurement_concept_id, measurement_date,
										 measurement_datetime, measurement_time, measurement_type_concept_id,
										 operator_concept_id, value_as_number, value_as_concept_id, unit_concept_id,
										 range_low, range_high, provider_id, visit_occurrence_id, visit_detail_id,
										 measurement_source_value, measurement_source_concept_id, unit_source_value,
										 value_source_value)
select * FROM cte6;

-- Update covid tests in measurement with concept_id and value_as_concept_id from covid_test_mappings
--update {TARGET_SCHEMA}.measurement m
--set value_as_concept_id = t.value_as_concept_id
--from {SOURCE_SCHEMA}.covid_test_mappings t
--where m.measurement_source_value = t.measurement_source_value
--;
--update {TARGET_SCHEMA}.measurement m
--set measurement_concept_id = t.concept_id
--from {SOURCE_SCHEMA}.covid_test_mappings t
--where m.measurement_source_value = t.measurement_source_value
--	and t.concept_id is not null
--;
--------------------------------
--insert into observation from stem. To increase performance, could we change the "not in" into "in" ?
--------------------------------
with cte7 as (
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
	from chunks.stem_{CHUNK_ID} s
	left join {TARGET_SCHEMA}.source_to_standard_vocab_map stsvm
		on s.unit_source_value = stsvm.source_code
		and stsvm.source_vocabulary_id = 'UCUM'
	join {TARGET_SCHEMA}.visit_occurrence v
		on s.visit_occurrence_id = v.visit_occurrence_id
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
update chunks.chunk 
set 
completed = 1
where chunk_id = {CHUNK_ID};