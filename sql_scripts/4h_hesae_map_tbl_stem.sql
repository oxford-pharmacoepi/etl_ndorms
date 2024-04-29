--drop index if exists {TARGET_SCHEMA}.idx_stem_source_concept_id;
--create index idx_stem_source_concept_id on {TARGET_SCHEMA}.stem_source (source_concept_id);
--
--drop index if exists {TARGET_SCHEMA}.idx_stem_domain_id;
--drop index if exists {TARGET_SCHEMA}.idx_procedure_person_id; -- NOT SURE WHERE THE PROCEDURE_OCCURRENCE TABLE IS USED ??
--drop index if exists {TARGET_SCHEMA}.idx_procedure_concept_id; -- NOT SURE WHERE THE PROCEDURE_OCCURRENCE TABLE IS USED ??
--drop index if exists {TARGET_SCHEMA}.idx_procedure_visit_id; -- NOT SURE WHERE THE PROCEDURE_OCCURRENCE TABLE IS USED ??
--

CREATE TABLE {CHUNK_SCHEMA}.stem_{CHUNK_ID} (LIKE {TARGET_SCHEMA}.STEM) TABLESPACE pg_default;

--insert into stem from stem_source, this is the vocab mapping portion
with cte1 as (
	SELECT 	v.target_domain_id, v.target_concept_id, s.*
	from {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} s
	left join {TARGET_SCHEMA}.source_to_standard_vocab_map v
		on s.source_concept_id = v.source_concept_id AND v.source_vocabulary_id = 'ICD10'
	WHERE s.source_concept_id <> 0
),
cte2 AS (
	SELECT 	v.target_domain_id, v.target_concept_id, s.*
	from {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} s
	left join {TARGET_SCHEMA}.source_to_standard_vocab_map v
		on s.source_value = v.source_code AND v.source_vocabulary_id = 'HESAE_DIAG_STCM'
	WHERE s.source_concept_id = 0 
),
cte3 AS (
	select * from cte1
	UNION 
	select * from cte2
)
insert into {CHUNK_SCHEMA}.stem_{CHUNK_ID} (domain_id, person_id, visit_occurrence_id, visit_detail_id, provider_id, id, concept_id, source_value,
										 source_concept_id, type_concept_id, start_date, end_date, start_time, days_supply, dose_unit_concept_id,
										 dose_unit_source_value, effective_drug_dose, lot_number, modifier_source_value, operator_concept_id, qualifier_concept_id,
										 qualifier_source_value, quantity, range_high, range_low, refills, route_concept_id, route_source_value,
										 sig, stop_reason, unique_device_id, unit_concept_id, unit_source_value, value_as_concept_id, value_as_number,
										 value_as_string, value_source_value, anatomic_site_concept_id, disease_status_concept_id, specimen_source_id,
										 anatomic_site_source_value, disease_status_source_value, modifier_concept_id, stem_source_table, stem_source_id)
	SELECT 
		case when target_domain_id is NULL then 'Observation' else target_domain_id end as domain_id,
		person_id,
		visit_occurrence_id,
		visit_detail_id,
		provider_id,
		row_number()over(order by person_id, start_date) + case when {CHUNK_ID} = 1 THEN 0 ELSE 
		(SELECT stem_id_end FROM {CHUNK_SCHEMA}.chunk where chunk_id = {CHUNK_ID}-1) end as id,
		case when target_concept_id is NULL then 0 else target_concept_id end as concept_id,
		source_value,
		source_concept_id,
		type_concept_id,
		start_date,
		end_date,
		start_time,
		days_supply,
		dose_unit_concept_id,
		dose_unit_source_value,
		effective_drug_dose,			
		lot_number,
		modifier_source_value,
		operator_concept_id,
		qualifier_concept_id,
		qualifier_source_value,
		quantity,
		range_high,
		range_low,
		refills,
		route_concept_id,
		route_source_value,
		sig, stop_reason, unique_device_id, unit_concept_id, unit_source_value, value_as_concept_id, value_as_number,
		value_as_string, value_source_value, anatomic_site_concept_id, disease_status_concept_id, specimen_source_id,
		anatomic_site_source_value, disease_status_source_value, modifier_concept_id,
		stem_source_table,
		stem_source_id
	from cte3;

ALTER TABLE {CHUNK_SCHEMA}.stem_{CHUNK_ID} ADD CONSTRAINT pk_stem_{CHUNK_ID} PRIMARY KEY (id) USING INDEX TABLESPACE pg_default;
create index idx_hesae_stem_domain_id_{CHUNK_ID} on {CHUNK_SCHEMA}.stem_{CHUNK_ID} (domain_id, visit_occurrence_id) TABLESPACE pg_default;
create index idx_hesae_stem_unit_source_value_{CHUNK_ID} on {CHUNK_SCHEMA}.stem_{CHUNK_ID} (unit_source_value) TABLESPACE pg_default;


-----------------------------------------
-- UPDATE CHUNK
-----------------------------------------
update {CHUNK_SCHEMA}.chunk 
set 
stem_tbl = concat('stem_',{CHUNK_ID}::varchar),
stem_id_start = (SELECT MIN(id) FROM {CHUNK_SCHEMA}.stem_{CHUNK_ID}),
stem_id_end = (SELECT MAX(id) FROM {CHUNK_SCHEMA}.stem_{CHUNK_ID})
where chunk_id = {CHUNK_ID};