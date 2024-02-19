--insert into temp table from hesae_diagnosis
CREATE TABLE IF NOT EXISTS {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (LIKE {TARGET_SCHEMA}.STEM_SOURCE);
--Inserting ICD10 diagnoses into stem_source table from hesae_diagnosis
WITH cte0 AS (
    SELECT person_id
    FROM {CHUNK_SCHEMA}.chunk_person
    WHERE chunk_id = {CHUNK_ID}
),
cte1 AS (
    SELECT 
        t1.person_id AS person_id,
        NULL::INT AS provider_id,
        t2.aekey::VARCHAR visit_source_value,
        t2.aekey::VARCHAR AS visit_detail_source_value,
        NULL::DATE AS start_date,
        NULL::DATE AS end_date,
        CASE 
            WHEN LENGTH(t2.diag) = 4 AND RIGHT(t2.diag, 1) IN ('X', '.')
            THEN LEFT(t2.diag, 3)
            WHEN LENGTH(t2.diag) = 4 
            THEN CONCAT(LEFT(t2.diag, 3), '.', RIGHT(t2.diag, 1))
            ELSE t2.diag
        END AS source_value, 
        CASE 
            WHEN t2.diag_order = 1 THEN 32902
            WHEN t2.diag_order > 1 THEN 32908
            ELSE NULL::INT
        END AS disease_status_concept_id,
        t2.diag_order AS disease_status_source_value,
		t2.aekey
    FROM cte0  AS t1
    INNER JOIN {SOURCE_SCHEMA}.hesae_diagnosis AS t2 ON t2.patid = t1.person_id
    ORDER BY t1.person_id, t2.aekey, t2.diag_order
),	
cte2 as (
		SELECT DISTINCT t4.*, t5.source_concept_id
		FROM cte1 as t4
		left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t5 on t5.source_code = t4.source_value
		WHERE upper(t5.source_vocabulary_id) = 'ICD10'
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
    b.person_id, 
    v.visit_occurrence_id,
    vd.visit_detail_id,
    b.provider_id,
    NULL::INT AS concept_id,
    b.source_value,
    b.source_concept_id,
    32818 AS type_concept_id,
    b.start_date,
    b.end_date,
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
    b.disease_status_concept_id,
    NULL::INT AS specimen_source_id,
    NULL AS anatomic_site_source_value, 
    b.disease_status_source_value, 
    NULL::INT AS modifier_concept_id,
    'hesae_diagnosis' AS stem_source_table,
    NULL AS stem_source_id
FROM cte2 AS b
INNER JOIN {TARGET_SCHEMA}.visit_occurrence AS v ON v.person_id = b.person_id AND v.visit_source_value = b.visit_source_value
INNER JOIN {TARGET_SCHEMA}.visit_detail AS vd ON b.person_id = vd.person_id AND b.visit_detail_source_value = vd.visit_detail_source_value
WHERE vd.visit_detail_concept_id = 9201;


--Inserting Read code diagnoses into stem_source table from hesae_diagnosis

WITH cte2 AS (
    SELECT person_id
    FROM {CHUNK_SCHEMA}.chunk_person
    WHERE chunk_id = {CHUNK_ID}
),
cte3 AS (
    SELECT
	    t1.person_id AS person_id,
        NULL::INT AS provider_id,
        t2.aekey::VARCHAR visit_source_value,
        t2.aekey::VARCHAR AS visit_detail_source_value,
        NULL::DATE AS start_date,
        NULL::DATE AS end_date,
		t3.cleansedreadcode as source_value, 
        CASE 
            WHEN t2.diag_order = 1 THEN 32902
            WHEN t2.diag_order > 1 THEN 32908
            ELSE NULL::INT
        END AS disease_status_concept_id,
        t2.diag_order AS disease_status_source_value 
    FROM
		cte2 as t1
    INNER JOIN {SOURCE_SCHEMA}.hesae_diagnosis AS t2 on t1.person_id = t2.patid
    INNER JOIN source.medicaldictionary AS t3 ON LEFT(t3.cleansedreadcode, 5) = LEFT(t2.diag, 5)
	ORDER BY t1.person_id, t2.aekey, t2.diag_order
),
cte4 as (
		SELECT DISTINCT t6.*, t7.source_concept_id
		FROM cte3 as t6
		left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t7 on t7.source_code = t6.source_value
		WHERE upper(t7.source_vocabulary_id) = 'READ'
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
    b.person_id, 
    v.visit_occurrence_id,
    vd.visit_detail_id,
    b.provider_id,
    NULL::INT AS concept_id,
    b.source_value,
    b.source_concept_id,
    32818 AS type_concept_id,
    b.start_date,
    b.end_date,
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
    b.disease_status_concept_id,
    NULL::INT AS specimen_source_id,
    NULL AS anatomic_site_source_value, 
    b.disease_status_source_value, 
    NULL::INT AS modifier_concept_id,
    'hesae_diagnosis' AS stem_source_table,
    NULL AS stem_source_id
FROM cte4 AS b
INNER JOIN {TARGET_SCHEMA}.visit_occurrence AS v ON v.person_id = b.person_id AND v.visit_source_value = b.visit_source_value
INNER JOIN {TARGET_SCHEMA}.visit_detail AS vd ON b.person_id = vd.person_id AND b.visit_detail_source_value = vd.visit_detail_source_value
WHERE vd.visit_detail_concept_id = 9201;

create index idx_stem_source_{CHUNK_ID} on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (source_concept_id);

-----------------------------------------
-- UPDATE CHUNK
-----------------------------------------
update {CHUNK_SCHEMA}.chunk 
set stem_source_tbl = concat('stem_source_',{CHUNK_ID}::varchar)
where chunk_id = {CHUNK_ID};