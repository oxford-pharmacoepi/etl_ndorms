--------------------------------
-- VISIT_OCCURRENCE
--------------------------------
DROP SEQUENCE IF EXISTS sequence_vo;
CREATE SEQUENCE sequence_vo INCREMENT 1;
SELECT setval('sequence_vo', (SELECT MAX(visit_occurrence_id) FROM public.visit_occurrence));
--SELECT setval('sequence_vo', (SELECT max_id from {TARGET_SCHEMA_TO_LINK}._max_ids WHERE lower(tbl_name) = 'visit_occurrence'));
 
with cte1 AS (
	SELECT person_id
	FROM {TARGET_SCHEMA}.person
),
cte2 AS (
	SELECT t2.aekey, MIN(t2.arrivaldate) AS date_min, 
	MAX(t2.arrivaldate) AS date_max
	FROM cte1 as t1
	INNER JOIN {SOURCE_SCHEMA}.hesae_attendance AS t2 ON t2.patid = t1.person_id
	GROUP BY t2.aekey
),
cte3 AS (
	SELECT
	NEXTVAL('sequence_vo') AS visit_occurrence_id,
	t1.patid AS person_id,
	9203 AS visit_concept_id,
	t3.date_min AS visit_start_date, 
	t3.date_min AS visit_start_datetime,
	t3.date_max AS visit_end_date,
	t3.date_max AS visit_end_datetime,
	32818 AS visit_type_concept_id,
	NULL::bigint AS provider_id,
	NULL::int AS care_site_id,
	t1.aekey AS visit_source_value,
	NULL::int AS visit_source_concept_id,
	t4.source_code_description AS admitting_source_value,
	t4.target_concept_id AS admitting_source_concept_id,
	NULL::int AS discharge_to_source_value,
	NULL::int AS discharge_to_concept_id,
	NULL::int AS preceding_visit_occurrence_id
	FROM {SOURCE_SCHEMA}.hesae_attendance AS t1
	INNER JOIN cte1 as t2 ON t1.patid = t2.person_id
	LEFT JOIN cte2 as t3 ON t1.aekey = t3.aekey
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.aerefsource = CAST(t4.source_code AS INTEGER) and t4.source_vocabulary_id = 'HESAE_REFSOURCE_STCM'
	GROUP BY t1.patid, t3.date_min,t3.date_max,t1.aekey,source_code_description,target_concept_id
),
cte4 AS (
	SELECT visit_occurrence_id,
	CASE WHEN visit_start_date <= visit_end_date 
		THEN visit_start_date ELSE visit_end_date 
	END AS visit_start_date,
	CASE WHEN visit_start_date <= visit_end_date 
		THEN visit_start_date ELSE visit_end_date 
	END AS visit_start_datetime,
	CASE WHEN visit_start_date <= visit_end_date 
		THEN visit_end_date ELSE visit_start_date 
	END AS visit_end_date,
	CASE WHEN visit_start_date <= visit_end_date 
		THEN visit_end_date ELSE visit_start_date 
	END AS visit_end_datetime
	FROM cte3
),
cte5 AS (
	SELECT t1.person_id, t1.visit_occurrence_id, MAX(t2.visit_occurrence_id) AS preceding_visit_occurrence_id 
	FROM cte3 AS t1
	INNER JOIN cte3 AS t2 ON t1.person_id = t2.person_id
	WHERE t1.visit_occurrence_id > t2.visit_occurrence_id
	GROUP BY t1.person_id, t1.visit_occurrence_id
)
INSERT INTO {TARGET_SCHEMA}.visit_occurrence (
	visit_occurrence_id,
	person_id,
	visit_concept_id,
	visit_start_date,
	visit_start_datetime,
	visit_end_date,
	visit_end_datetime,
	visit_type_concept_id,
	provider_id,
	care_site_id,
	visit_source_value,
	visit_source_concept_id,
	admitting_source_value,
	admitting_source_concept_id,
	discharge_to_source_value,
	discharge_to_concept_id,
	preceding_visit_occurrence_id
)
SELECT
	t1.visit_occurrence_id,
	t1.person_id,
	t1.visit_concept_id,
	t2.visit_start_date, 
	t2.visit_start_datetime,
	t2.visit_end_date,
	t2.visit_end_datetime,
	t1.visit_type_concept_id,
	t1.provider_id,
	t1.care_site_id,
	t1.visit_source_value,
	t1.visit_source_concept_id,
	t1.admitting_source_value,
	t1.admitting_source_concept_id,
	t1.discharge_to_source_value,
	t1.discharge_to_concept_id,
	t3.preceding_visit_occurrence_id
	FROM cte3 AS t1
	INNER JOIN cte4 AS t2 ON t1.visit_occurrence_id = t2.visit_occurrence_id
	LEFT JOIN cte5 AS t3 ON t1.visit_occurrence_id = t3.visit_occurrence_id;
 
DROP SEQUENCE IF EXISTS sequence_vo;
 
ALTER TABLE {TARGET_SCHEMA}.visit_occurrence ADD CONSTRAINT xpk_visit_occurrence PRIMARY KEY (visit_occurrence_id);
CREATE INDEX idx_visit_occurrence_person_id ON {TARGET_SCHEMA}.visit_occurrence (person_id, visit_start_date);
CLUSTER {TARGET_SCHEMA}.visit_occurrence USING idx_visit_occurrence_person_id;
CREATE INDEX idx_visit_concept_id ON {TARGET_SCHEMA}.visit_occurrence (visit_concept_id ASC); --The values are all the same: why do an index help??
CREATE INDEX idx_visit_source_value ON {TARGET_SCHEMA}.visit_occurrence (visit_source_value ASC);
 
--------------------------------
-- VISIT_DETAIL
--------------------------------
-- VISIT_DETAIL FROM hes_episodes
--------------------------------
DROP SEQUENCE IF EXISTS sequence_vd;
CREATE SEQUENCE sequence_vd INCREMENT 1; 
SELECT setval('sequence_vd', (SELECT MAX(visit_detail_id) from public.visit_detail));
--SELECT setval('sequence_vd', (SELECT max_id from {TARGET_SCHEMA_TO_LINK}._max_ids WHERE lower(tbl_name) = 'visit_detail'));
 
WITH cte1 AS (
	SELECT 
	t1.patid AS person_id,
	9203 AS visit_detail_concept_id,
	t1.arrivaldate AS visit_detail_start_date,
	t1.arrivaldate AS visit_detail_start_datetime,
	t1.arrivaldate  AS visit_detail_end_date,
	t1.arrivaldate AS visit_detail_end_datetime,
	32818 AS visit_detail_type_concept_id,
	NULL::int AS provider_id,
	NULL::int AS care_site_id,
	t1.aekey AS visit_detail_source_value,
	NULL::int AS visit_detail_source_concept_id,
	t2.source_code_description AS admitting_source_value,	-- ANTO: definition to be added instead of number
	t2.target_concept_id AS admitting_source_concept_id,				-- to be implemented FROM AEREFSOURCE
	NULL::int  AS discharge_to_source_value,		-- ANTO: definition to be added instead of number
	NULL::int  AS discharge_to_concept_id,			
	NULL::int AS preceding_visit_detail_id, 					-- ANTO: to be filled in later when the table is all filled in
	NULL::int AS visit_detail_parent_id,
	NULL::int as visit_occurrence_id,
	t1.aekey
	FROM {SOURCE_SCHEMA}.hesae_attendance AS t1
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t1.aerefsource = CAST(t2.source_code AS INTEGER) and t2.source_vocabulary_id = 'HESAE_REFSOURCE_STCM'
	GROUP BY t1.patid,t1.aekey,t2.source_code_description,t2.target_concept_id
 
),
cte2 AS (
	SELECT person_id, visit_detail_source_value,
	CASE WHEN visit_detail_start_date <= visit_detail_end_date 
		THEN visit_detail_start_date ELSE visit_detail_end_date 
	END AS visit_detail_start_date,
	CASE WHEN visit_detail_start_date <= visit_detail_end_date 
		THEN visit_detail_start_date ELSE visit_detail_end_date 
	END AS visit_detail_start_datetime,
	CASE WHEN visit_detail_start_date <= visit_detail_end_date 
		THEN visit_detail_end_date ELSE visit_detail_start_date 
	END AS visit_detail_end_date,
	CASE WHEN visit_detail_start_date <= visit_detail_end_date 
		THEN visit_detail_end_date ELSE visit_detail_start_date 
	END AS visit_detail_end_datetime
	FROM cte1
),
cte3 AS (
	SELECT 
	t1.person_id,
	t1.visit_detail_concept_id,
	t2.visit_detail_start_date,
	t2.visit_detail_start_datetime,
	t2.visit_detail_end_date,
	t2.visit_detail_end_datetime,
	t1.visit_detail_type_concept_id,
	t1.provider_id,
	t1.care_site_id,
	t1.visit_detail_source_value,
	t1.visit_detail_source_concept_id,
	t1.admitting_source_value,
	t1.admitting_source_concept_id,	
	t1.discharge_to_source_value,
	t1.discharge_to_concept_id,
	t1.preceding_visit_detail_id,
	t1.visit_detail_parent_id,
	t1.visit_occurrence_id,
	t1.aekey
	FROM cte1 AS t1
	INNER JOIN cte2 AS t2 ON t1.person_id = t2.person_id AND t1.visit_detail_source_value = t2.visit_detail_source_value
),
cte4 AS (
	SELECT * FROM cte3
	ORDER BY person_id, visit_detail_source_value, visit_detail_start_datetime
),
cte5 AS (
	SELECT 
	NEXTVAL('sequence_vd') AS visit_detail_id, 
	t1.person_id,	
	t1.visit_detail_concept_id,
	t1.visit_detail_start_date,
	t1.visit_detail_start_datetime,
	t1.visit_detail_end_date,
	t1.visit_detail_end_datetime,
	t1.visit_detail_type_concept_id,
	t1.provider_id,
	t1.care_site_id,
	t1.visit_detail_source_value,
	t1.visit_detail_source_concept_id,
	t1.admitting_source_value,
	t1.admitting_source_concept_id,
	t1.discharge_to_source_value,
	t1.discharge_to_concept_id,
	t1.preceding_visit_detail_id, 
	t1.visit_detail_parent_id,
	t2.visit_occurrence_id
	FROM cte4 as t1
	INNER JOIN {TARGET_SCHEMA}.visit_occurrence AS t2 ON t2.visit_source_value::bigint = t1.aekey
),
cte6 AS (
	SELECT t1.person_id, t1.visit_detail_id, MAX(t2.visit_detail_id) AS preceding_visit_detail_id 
	FROM cte5 AS t1
	INNER JOIN cte5 AS t2 ON t1.person_id = t2.person_id
	WHERE t1.visit_detail_id > t2.visit_detail_id
	GROUP BY t1.person_id, t1.visit_detail_id
)
INSERT INTO {TARGET_SCHEMA}.VISIT_DETAIL (
	visit_detail_id,
	person_id,
	visit_detail_concept_id,
	visit_detail_start_date,
	visit_detail_start_datetime,
	visit_detail_end_date,
	visit_detail_end_datetime,
	visit_detail_type_concept_id,
	provider_id,
	care_site_id,
	visit_detail_source_value,
	visit_detail_source_concept_id,
	admitting_source_value,
	admitting_source_concept_id,
	discharge_to_source_value,
	discharge_to_concept_id,
	preceding_visit_detail_id,
	visit_detail_parent_id,
	visit_occurrence_id
)
SELECT
	t1.visit_detail_id,
	t1.person_id,
	t1.visit_detail_concept_id,
	t1.visit_detail_start_date,
	t1.visit_detail_start_datetime,
	t1.visit_detail_end_date,
	t1.visit_detail_end_datetime,
	t1.visit_detail_type_concept_id,
	t1.provider_id,
	t1.care_site_id,
	t1.visit_detail_source_value,
	t1.visit_detail_source_concept_id,
	t1.admitting_source_value,
	t1.admitting_source_concept_id,
	t1.discharge_to_source_value,
	t1.discharge_to_concept_id,
	t2.preceding_visit_detail_id,
	t1.visit_detail_parent_id,
	t1.visit_occurrence_id
FROM cte5 as t1
LEFT JOIN cte6 AS t2 ON t1.visit_detail_id = t2.visit_detail_id;
 
DROP SEQUENCE IF EXISTS sequence_vd;
 
ALTER TABLE {TARGET_SCHEMA}.visit_detail ADD CONSTRAINT xpk_visit_detail PRIMARY KEY (visit_detail_id);	
CREATE INDEX idx_visit_detail_person_id  ON {TARGET_SCHEMA}.visit_detail (person_id, visit_detail_source_value);
CLUSTER {TARGET_SCHEMA}.visit_detail USING idx_visit_detail_person_id;
CREATE INDEX idx_visit_detail_concept_id ON {TARGET_SCHEMA}.visit_detail (visit_detail_concept_id ASC);
CREATE INDEX idx_visit_detail_occurrence_id ON {TARGET_SCHEMA}.visit_detail (visit_occurrence_id ASC);