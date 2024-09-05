--insert into temp table from hesin_diag
CREATE TABLE {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (LIKE {TARGET_SCHEMA}.STEM_SOURCE) TABLESPACE pg_default;

WITH cte0 as (
		select person_id
		from {CHUNK_SCHEMA}.chunk_person
		where chunk_id = {CHUNK_ID}
	),
	cte1 as (
		select 
		t2.eid as person_id, 
		NULL::bigint as provider_id, 
		t2.ins_index::varchar as visit_source_value, 
		t2.arr_index::varchar as visit_detail_source_value, 
		t3.epistart as start_date, 
		t3.epistart as end_date,
		CASE 
			WHEN LENGTH(COALESCE(t2.diag_icd9, t2.diag_icd10)) = 4 
			THEN CONCAT(LEFT(COALESCE(t2.diag_icd9, t2.diag_icd10), 3), '.', RIGHT(COALESCE(t2.diag_icd9, t2.diag_icd10), 1)) 
			ELSE COALESCE(t2.diag_icd9, t2.diag_icd10)  
		END AS source_value,
		CASE WHEN t2.level = 1 THEN 32902
			 WHEN t2.level > 1 THEN 32908
			 ELSE NULL::int
		END AS disease_status_concept_id,
		t2.level AS disease_status_source_value,
		t2.arr_index
		from cte0 as t1
		inner join {SOURCE_SCHEMA}.hesin_diag as t2 on t1.person_id = t2.eid
		LEFT JOIN source_ukb_hesin.hesin as t3 on t2.eid = t3.eid and t2.ins_index = t3.ins_index
		order by t2.eid, t2.ins_index, t2.arr_index, t2.level
	),
	cte2 as (
		SELECT DISTINCT t1.*, t2.source_concept_id
		FROM cte1 as t1
		left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_code = t1.source_value
		WHERE upper(t2.source_vocabulary_id) IN ('ICD9CM','ICD10')

	)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (domain_id, person_id, visit_occurrence_id, visit_detail_id, provider_id, concept_id, source_value,
					 source_concept_id, type_concept_id, start_date, end_date, start_time, days_supply, dose_unit_concept_id,
					 dose_unit_source_value, effective_drug_dose, lot_number, modifier_source_value, 
					 operator_concept_id, qualifier_concept_id, qualifier_source_value, quantity, 
					 range_high, range_low, refills, route_concept_id, route_source_value, sig, stop_reason, unique_device_id, unit_concept_id,
					 unit_source_value, value_as_concept_id, value_as_number, value_as_string,
					 value_source_value, anatomic_site_concept_id, disease_status_concept_id, specimen_source_id, anatomic_site_source_value, disease_status_source_value, 
					 modifier_concept_id, stem_source_table, stem_source_id)
select 
	NULL as domain_id,
	t1.person_id, 
	t2.visit_occurrence_id,
	t3.visit_detail_id,
	t1.provider_id,
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
	'hesin_diag' stem_source_table,
	NULL as stem_source_id
from cte2 as t1
inner join {TARGET_SCHEMA}.visit_occurrence as t2 on t1.person_id = t2.person_id and t1.visit_source_value = t2.visit_source_value
inner join {TARGET_SCHEMA}.visit_detail as t3 on t1.person_id = t3.person_id and t1.visit_detail_source_value = t3.visit_detail_source_value
WHERE t3.visit_detail_concept_id = 9201;	

--insert into stem_source table from hesin_oper
WITH cte0 as (
		select person_id
		from {CHUNK_SCHEMA}.chunk_person
		where chunk_id = {CHUNK_ID}
	),
	cte1 as (
		select t2.eid as person_id, 
		NULL::bigint as provider_id, 
		t2.ins_index::varchar as visit_source_value, 
		t2.arr_index::varchar as visit_detail_source_value, 
		COALESCE(t2.opdate,t3.epistart) as start_date, 
		COALESCE(t2.opdate,t3.epistart) as end_date,
		CASE 
			WHEN LENGTH(t2.oper4) = 4 
			THEN CONCAT(LEFT(t2.oper4, 3), '.', RIGHT(t2.oper4, 1)) 
			ELSE t2.oper4
		END AS source_value,
		t2.level AS modifier_source_value
		from cte0 as t1
		INNER join {SOURCE_SCHEMA}.hesin_oper as t2 on t1.person_id = t2.eid
		LEFT join {SOURCE_SCHEMA}.hesin as t3 on t2.eid = t3.eid and t2.ins_index = t3.ins_index
		order by t2.eid, t2.ins_index, COALESCE(t2.opdate,t3.epistart,t3.admidate), level),
	cte2 as (
		SELECT DISTINCT t1.*, t2.source_concept_id
		FROM cte1 as t1
		left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_code = t1.source_value
		WHERE upper(t2.source_vocabulary_id) = 'OPCS4'

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
	t1.provider_id,
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
	'hesin_oper' stem_source_table,
	NULL as stem_source_id
from cte2 as t1
inner join {TARGET_SCHEMA}.visit_occurrence as t2 on t1.person_id = t2.person_id and t1.visit_source_value = t2.visit_source_value
inner join {TARGET_SCHEMA}.visit_detail as t3 on t1.person_id = t3.person_id and t1.visit_detail_source_value = t3.visit_detail_source_value
WHERE t3.visit_detail_concept_id = 9201;


create index idx_stem_source_{CHUNK_ID} on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (source_concept_id) TABLESPACE pg_default;

-----------------------------------------
-- UPDATE CHUNK
-----------------------------------------
update {CHUNK_SCHEMA}.chunk 
set stem_source_tbl = concat('stem_source_',{CHUNK_ID}::varchar)
where chunk_id = {CHUNK_ID};