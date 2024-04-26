CREATE TABLE IF NOT EXISTS {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (LIKE {TARGET_SCHEMA}.STEM_SOURCE) TABLESPACE pg_default;

--Insert hesae_diagnosis into stem_source table
--DIAGSCHEME = 1 => Accident & Emergency (large majority)
--DIAGSCHEME = 2 => ICD10 (small number)
--DIAGSCHEME = 4 => Read coded v2 (just a few at the moment, not implemented)
--DIAGSCHEME = Null = Not known
--DIAGSCHEME NOT RELIABLE: NOT USED

WITH cte0 AS (
    SELECT person_id
    FROM {CHUNK_SCHEMA}.chunk_person
	WHERE chunk_id = {CHUNK_ID}
),
cte1 AS (
	SELECT DISTINCT 
		t1.person_id,
		NULL::INT AS provider_id,
		t2.aekey::VARCHAR AS visit_detail_source_value,
		t3.arrivaldate AS start_date,
		t3.arrivaldate AS end_date,
		CASE WHEN LENGTH(t2.diag) = 2 OR LENGTH(t2.diag) = 3 
			THEN t2.diag ELSE TRIM(LEFT(t2.diag,3)) END AS source_value, 
		CASE 
			WHEN t2.diag_order = 1 THEN 32902
			WHEN t2.diag_order > 1 THEN 32908
		END AS disease_status_concept_id,
		t2.diag_order AS disease_status_source_value
	FROM 
		cte0 AS t1
		INNER JOIN {SOURCE_SCHEMA}.hesae_diagnosis t2 ON t2.patid = t1.person_id
		INNER JOIN {SOURCE_SCHEMA}.hesae_attendance t3 ON t2.patid = t3.patid AND t2.aekey = t3.aekey
		WHERE LEFT(t2.diag,1) ~ '\d' --If it is a number 		t2.DIAGSCHEME = 1
),	
cte2 as (
	SELECT DISTINCT t1.*, t2.source_concept_id
	FROM cte1 as t1
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_concept_map as t2 on t2.source_code = t1.source_value AND
		t2.source_vocabulary_id IN ('HESAE_DIAG_STCM')
),
cte3 AS (
	SELECT DISTINCT
		t1.person_id,
		NULL::INT AS provider_id,
		t2.aekey::VARCHAR AS visit_detail_source_value,
		t3.arrivaldate AS start_date,
		t3.arrivaldate AS end_date,
		CASE WHEN LENGTH(RTRIM(t2.diag,'X')) = 4 AND RIGHT(RTRIM(t2.diag,'X'),1) = '.' THEN LEFT(RTRIM(t2.diag,'X'),3)
			 WHEN LENGTH(RTRIM(t2.diag,'X')) = 4 AND RTRIM(t2.diag,'X') NOT LIKE '%.%' THEN LEFT(RTRIM(t2.diag,'X'),3) || '.' || RIGHT(RTRIM(t2.diag,'X'),1)
			 WHEN LENGTH(RTRIM(t2.diag,'X')) = 5 AND RTRIM(t2.diag,'X') LIKE '%.%' THEN RTRIM(t2.diag,'X')
			 WHEN LENGTH(RTRIM(t2.diag,'X')) = 5 AND RTRIM(t2.diag,'X') NOT LIKE '%.%' THEN LEFT(RTRIM(t2.diag,'X'),3) || '.' || RIGHT(RTRIM(t2.diag,'X'),2)
			ELSE RTRIM(t2.diag,'X')
		END AS source_value, 
		CASE 
			WHEN t2.diag_order = 1 THEN 32902
			WHEN t2.diag_order > 1 THEN 32908
		END AS disease_status_concept_id,
		t2.diag_order AS disease_status_source_value
	FROM 
		cte0 AS t1
		INNER JOIN {SOURCE_SCHEMA}.hesae_diagnosis t2 ON t2.patid = t1.person_id
		INNER JOIN {SOURCE_SCHEMA}.hesae_attendance t3 ON t2.patid = t3.patid AND t2.aekey = t3.aekey
		WHERE LEFT(t2.diag,1) !~ '\d' --If it is NOT a number 	--t2.DIAGSCHEME = 2
),	
cte4 as (
	SELECT DISTINCT t1.*, t2.source_concept_id
	FROM cte3 as t1
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_code = t1.source_value
		AND t2.source_vocabulary_id IN ('ICD10')
),
cte5 as (
	SELECT * FROM cte2
	UNION 
	SELECT * FROM cte4
	ORDER BY person_id, visit_detail_source_value, disease_status_source_value
)
INSERT INTO {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
    domain_id, person_id, visit_occurrence_id, visit_detail_id, provider_id, concept_id, source_value,
    source_concept_id, type_concept_id, start_date, end_date, start_time, days_supply, dose_unit_concept_id,
    dose_unit_source_value, effective_drug_dose, lot_number, modifier_source_value, 
    operator_concept_id, qualifier_concept_id, qualifier_source_value, quantity, 
    range_high, range_low, refills, route_concept_id, route_source_value, sig, stop_reason, unique_device_id, unit_concept_id,
    unit_source_value, value_as_concept_id, value_as_number, value_as_string,
    value_source_value, anatomic_site_concept_id, disease_status_concept_id, specimen_source_id, anatomic_site_source_value, disease_status_source_value, 
    modifier_concept_id, stem_source_table, stem_source_id
)
SELECT 
    NULL AS domain_id,
    t1.person_id, 
    t2.visit_occurrence_id,
    t2.visit_detail_id,
    t1.provider_id,
    NULL::INT AS concept_id,
    t1.source_value,
    t1.source_concept_id,
    32818 AS type_concept_id,
    t1.start_date,
    t1.end_date,
    '00:00:00'::TIME AS start_time,
    NULL AS days_supply,
    NULL::INT AS dose_unit_concept_id,
    NULL AS dose_unit_source_value, 
    NULL AS effective_drug_dose, 
    NULL AS lot_number, 
    NULL AS modifier_source_value,
    NULL::INT AS operator_concept_id,
    NULL::INT AS qualifier_concept_id,
    NULL AS qualifier_source_value, 
    NULL AS quantity, 
    NULL::DOUBLE PRECISION AS range_high,
    NULL::DOUBLE PRECISION AS range_low,
    NULL AS refills,
    NULL::INT AS route_concept_id,
    NULL AS route_source_value,
    NULL::INT AS unit_concept_id,
    NULL AS sig, 
    NULL AS stop_reason, 
    NULL::INT AS unique_device_id,
    NULL AS unit_source_value,
    NULL::INT AS value_as_concept_id,
    NULL AS value_as_number,
    NULL AS value_as_string,
    NULL AS value_source_value,
    NULL::INT AS anatomic_site_concept_id,
    t1.disease_status_concept_id,
    NULL::INT AS specimen_source_id,
    NULL AS anatomic_site_source_value, 
    t1.disease_status_source_value, 
    NULL::INT AS modifier_concept_id,
    'hesae_diagnosis' AS stem_source_table,
    NULL AS stem_source_id
FROM cte5 AS t1
INNER JOIN {TARGET_SCHEMA}.visit_detail AS t2 ON t1.person_id = t2.person_id AND t1.visit_detail_source_value = t2.visit_detail_source_value;

create index idx_hesae_stem_source_{CHUNK_ID} on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (source_concept_id) TABLESPACE pg_default;

-----------------------------------------
-- UPDATE CHUNK
-----------------------------------------
update {CHUNK_SCHEMA}.chunk 
set stem_source_tbl = concat('stem_source_',{CHUNK_ID}::varchar)
where chunk_id = {CHUNK_ID};