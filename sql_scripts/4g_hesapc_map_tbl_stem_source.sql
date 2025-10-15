--insert into temp table from hes_diagnosis_epi
CREATE TABLE {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (LIKE {TARGET_SCHEMA}.STEM_SOURCE) TABLESPACE pg_default;

WITH cte0 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
),
cte1 as (
	select t2.patid as person_id, 
	NULL as provider_id, 
	t2.spno::varchar as visit_source_value, 
	t2.epikey::varchar as visit_detail_source_value, 
	t2.epistart as start_date, 
	t2.epiend as end_date,
	t2.icd as source_value, 
	CASE WHEN d_order = 1 THEN 32902
		 WHEN d_order > 1 THEN 32908
		 ELSE NULL::int
	END AS disease_status_concept_id,
	d_order AS disease_status_source_value
	from cte0 as t1
	inner join {SOURCE_SCHEMA}.hes_diagnosis_epi as t2 on t1.person_id = t2.patid
	order by t2.patid, t2.epikey, t2.epistart, d_order
),
cte2 as (
	SELECT DISTINCT t1.*, t2.source_concept_id
	FROM cte1 as t1
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_code = t1.source_value
	WHERE upper(t2.source_vocabulary_id) = 'ICD10'
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (domain_id, person_id, visit_occurrence_id, visit_detail_id, provider_id, concept_id, source_value,
					 source_concept_id, type_concept_id, start_date, end_date, start_time, days_supply, dose_unit_concept_id,
					 dose_unit_source_value, effective_drug_dose, lot_number, modifier_source_value, 
					 operator_concept_id, qualifier_concept_id, qualifier_source_value, quantity, 
					 range_high, range_low, refills, route_concept_id, route_source_value, sig, stop_reason, unique_device_id, unit_concept_id,
					 unit_source_value, value_as_concept_id, value_as_number, value_as_string,
					 value_source_value, anatomic_site_concept_id, disease_status_concept_id, specimen_source_id, anatomic_site_source_value, disease_status_source_value, 
					 modifier_concept_id, stem_source_table, stem_source_id)
select NULL as domain_id,
	t1.person_id, 
	t2.visit_occurrence_id,
	t3.visit_detail_id,
	t3.provider_id,
	NULL::int as concept_id,
	t1.source_value,
	t1.source_concept_id,
	32829 as type_concept_id,
	t1.start_date,
	t1.end_date,
	'00:00:00'::time start_time,
	NULL as days_supply,
	NULL::int as dose_unit_concept_id,
	NULL as dose_unit_source_value, 
	NULL as effective_drug_dose, 
	NULL as lot_number, 
	NULL as modifier_source_value,
	NULL::int as operator_concept_id,
	NULL::int as qualifier_concept_id,
	NULL as qualifier_source_value, 
	NULL as quantity, 
	NULL::double precision range_high,
	NULL::double precision range_low,
	NULL as refills,
	NULL::int as route_concept_id,
	NULL as route_source_value,
	NULL::int as unit_concept_id,
	NULL as sig, 
	NULL as stop_reason, 
	NULL::int as unique_device_id,
	NULL as unit_source_value,
	NULL::int as value_as_concept_id,
	NULL AS value_as_number,
	NULL as value_as_string,
	NULL AS value_source_value,
	NULL::int as anatomic_site_concept_id,
	t1.disease_status_concept_id,
	NULL::int as specimen_source_id,
	NULL as anatomic_site_source_value, 
	t1.disease_status_source_value, 
	NULL::int as modifier_concept_id,
	'hes_diagnosis_epi' stem_source_table,
	NULL as stem_source_id
from cte2 as t1
inner join {TARGET_SCHEMA}.visit_occurrence as t2 on t1.visit_source_value = t2.visit_source_value
inner join {TARGET_SCHEMA}.visit_detail as t3 on t1.person_id = t3.person_id and t1.visit_detail_source_value = t3.visit_detail_source_value
WHERE t3.visit_detail_concept_id = 9201;


--insert into stem_source table from hes_procedures_epi
WITH cte0 as (
		select person_id
		from {CHUNK_SCHEMA}.chunk_person
		where chunk_id = {CHUNK_ID}
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (domain_id, person_id, visit_occurrence_id, visit_detail_id, provider_id, concept_id, source_value,
					 source_concept_id, type_concept_id, start_date, end_date, start_time, days_supply, dose_unit_concept_id,
					 dose_unit_source_value, effective_drug_dose, lot_number, modifier_source_value, 
					 operator_concept_id, qualifier_concept_id, qualifier_source_value, quantity, 
					 range_high, range_low, refills, route_concept_id, route_source_value, sig, stop_reason, unique_device_id, unit_concept_id,
					 unit_source_value, value_as_concept_id, value_as_number, value_as_string,
					 value_source_value, anatomic_site_concept_id, disease_status_concept_id, specimen_source_id, anatomic_site_source_value, disease_status_source_value, 
					 modifier_concept_id, stem_source_table, stem_source_id)
select NULL as domain_id,
	t1.person_id, 
	t2.visit_occurrence_id,
	t3.visit_detail_id,
	t3.provider_id,
	NULL::int as concept_id,
	t1.source_value,
	t1.source_concept_id,
	32829 as type_concept_id,
	t1.start_date,
	t1.end_date,
	'00:00:00'::time start_time,
	NULL as days_supply,
	NULL::int as dose_unit_concept_id,
	NULL as dose_unit_source_value, 
	NULL as effective_drug_dose, 
	NULL as lot_number, 
	t1.modifier_source_value,
	NULL::int as operator_concept_id,
	NULL::int as qualifier_concept_id,
	NULL as qualifier_source_value, 
	NULL as quantity, 
	NULL::double precision range_high,
	NULL::double precision range_low,
	NULL as refills,
	NULL::int as route_concept_id,
	NULL as route_source_value,
	NULL::int as unit_concept_id,
	NULL as sig, 
	NULL as stop_reason, 
	NULL::int as unique_device_id,
	NULL as unit_source_value,
	NULL::int as value_as_concept_id,
	NULL AS value_as_number,
	NULL as value_as_string,
	NULL AS value_source_value,
	NULL::int as anatomic_site_concept_id,
	NULL::int AS disease_status_concept_id,
	NULL::int as specimen_source_id,
	NULL as anatomic_site_source_value, 
	NULL::int AS disease_status_source_value, 
	NULL::int as modifier_concept_id,
	'hes_procedures_epi' stem_source_table,
	NULL as stem_source_id
from cte2 as t1
inner join {TARGET_SCHEMA}.visit_occurrence as t2 on t1.visit_source_value = t2.visit_source_value
inner join {TARGET_SCHEMA}.visit_detail as t3 on t1.person_id = t3.person_id and t1.visit_detail_source_value = t3.visit_detail_source_value
WHERE t3.visit_detail_concept_id = 9201;	

create index idx_stem_source_{CHUNK_ID} on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (source_concept_id) TABLESPACE pg_default;

-----------------------------------------
-- UPDATE CHUNK
-----------------------------------------
update {CHUNK_SCHEMA}.chunk 
set stem_source_tbl = concat('stem_source_',{CHUNK_ID}::varchar)
where chunk_id = {CHUNK_ID};