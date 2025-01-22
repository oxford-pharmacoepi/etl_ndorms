CREATE TABLE {CHUNK_SCHEMA}.stem_{CHUNK_ID} (LIKE {TARGET_SCHEMA}.STEM) TABLESPACE pg_default;

--insert into stem from stem_source, this is the vocab mapping portion
with cte as (
	SELECT distinct case when v.target_domain_id is NULL
				then 'Observation'
				else v.target_domain_id
			end as domain_id,
			s.person_id,
			s.visit_occurrence_id,
			s.visit_detail_id,
			s.provider_id,
			case when v.target_concept_id is NULL then 0
				 else v.target_concept_id
			end as concept_id,
			s.source_value,
			s.source_concept_id,
			s.type_concept_id,
			s.start_date,
			s.end_date,
			s.start_time,
			s.days_supply,
			s.dose_unit_concept_id,
			s.dose_unit_source_value,
			s.effective_drug_dose,			
			s.lot_number,
			s.modifier_source_value,
			s.operator_concept_id,
			s.qualifier_concept_id,
			s.qualifier_source_value,
			s.quantity,
			s.range_high,
			s.range_low,
			s.refills,
			s.route_concept_id,
			s.route_source_value,
			s.sig, s.stop_reason, s.unique_device_id, s.unit_concept_id, s.unit_source_value, s.value_as_concept_id, s.value_as_number,
			s.value_as_string, s.value_source_value, s.anatomic_site_concept_id, s.disease_status_concept_id, s.specimen_source_id,
			s.anatomic_site_source_value, s.disease_status_source_value, s.modifier_concept_id,
			s.stem_source_table,
			s.stem_source_id
	from {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} s
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map v
		on s.source_concept_id = v.source_concept_id
		and s.source_concept_id <> 0
)
insert into {CHUNK_SCHEMA}.stem_{CHUNK_ID} (domain_id, person_id, visit_occurrence_id, visit_detail_id, provider_id, id, concept_id, source_value,
										 source_concept_id, type_concept_id, start_date, end_date, start_time, days_supply, dose_unit_concept_id,
										 dose_unit_source_value, effective_drug_dose, lot_number, modifier_source_value, operator_concept_id, qualifier_concept_id,
										 qualifier_source_value, quantity, range_high, range_low, refills, route_concept_id, route_source_value,
										 sig, stop_reason, unique_device_id, unit_concept_id, unit_source_value, value_as_concept_id, value_as_number,
										 value_as_string, value_source_value, anatomic_site_concept_id, disease_status_concept_id, specimen_source_id,
										 anatomic_site_source_value, disease_status_source_value, modifier_concept_id, stem_source_table, stem_source_id)
	select 	domain_id,
			person_id,
			visit_occurrence_id,
			visit_detail_id,
			provider_id,
			row_number()over(order by person_id, start_date, end_date) + case when {CHUNK_ID} = 1 THEN 0 ELSE 
			(SELECT stem_id_end FROM {CHUNK_SCHEMA}.chunk where chunk_id = {CHUNK_ID}-1) end as id,
			concept_id,
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
	from cte;

ALTER TABLE {CHUNK_SCHEMA}.stem_{CHUNK_ID} ADD CONSTRAINT pk_stem_{CHUNK_ID} PRIMARY KEY (id) USING INDEX TABLESPACE pg_default;
create index idx_stem_domain_id_{CHUNK_ID} on {CHUNK_SCHEMA}.stem_{CHUNK_ID} (domain_id, visit_occurrence_id) TABLESPACE pg_default;
create index idx_stem_unit_source_value_{CHUNK_ID} on {CHUNK_SCHEMA}.stem_{CHUNK_ID} (unit_source_value) TABLESPACE pg_default;


-----------------------------------------
-- UPDATE CHUNK
-----------------------------------------
update {CHUNK_SCHEMA}.chunk 
set 
stem_tbl = concat('stem_',{CHUNK_ID}::varchar),
stem_id_start = (SELECT MIN(id) FROM {CHUNK_SCHEMA}.stem_{CHUNK_ID}),
stem_id_end = (SELECT MAX(id) FROM {CHUNK_SCHEMA}.stem_{CHUNK_ID})
where chunk_id = {CHUNK_ID};