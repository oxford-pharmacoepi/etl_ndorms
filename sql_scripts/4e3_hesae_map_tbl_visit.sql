--------------------------------
-- VISIT_OCCURRENCE from hesae_attendance
--------------------------------
DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_vo;
CREATE SEQUENCE {TARGET_SCHEMA}.sequence_vo INCREMENT 1;
SELECT setval('{TARGET_SCHEMA}.sequence_vo', (SELECT next_id from {TARGET_SCHEMA}._next_ids WHERE lower(tbl_name) = 'visit_occurrence'));

with cte1 AS (
	SELECT person_id, observation_period_start_date, observation_period_end_date
	FROM {TARGET_SCHEMA}.observation_period
),
cte2 AS (
	SELECT
	t2.patid AS person_id,
	9203 AS visit_concept_id,
	t2.arrivaldate AS visit_start_date, 
	t2.arrivaldate AS visit_start_datetime,
	t2.arrivaldate AS visit_end_date,
	t2.arrivaldate AS visit_end_datetime,
	32818 AS visit_type_concept_id,
	NULL::bigint AS provider_id,
	NULL::int AS care_site_id,
	t2.aekey AS visit_source_value,
	NULL::int AS visit_source_concept_id,
	t3.source_code_description AS admitting_source_value,
	t3.target_concept_id AS admitting_source_concept_id,
	NULL AS discharge_to_source_value,
	NULL::bigint AS discharge_to_concept_id,
	NULL::bigint AS preceding_visit_occurrence_id
	FROM cte1 as t1	
	INNER JOIN {SOURCE_SCHEMA}.hesae_attendance AS t2 ON t1.person_id = t2.patid
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_concept_map as t3 on t2.aerefsource = t3.source_code::int and t3.source_vocabulary_id = 'HESAE_REFSOURCE_STCM'
),
cte3 AS (
	SELECT person_id, visit_source_value,
	LEAST(visit_start_date, visit_end_date) AS visit_start_date,
	LEAST(visit_start_date, visit_end_date) AS visit_start_datetime,
	GREATEST(visit_start_date, visit_end_date) AS visit_end_date,
	GREATEST(visit_start_date, visit_end_date) AS visit_end_datetime
	FROM cte2
),
cte4 AS (
	SELECT
	NEXTVAL('{TARGET_SCHEMA}.sequence_vo') AS visit_occurrence_id, 
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
	t1.preceding_visit_occurrence_id
	from cte2 as t1
	inner join cte3 as t2 on t1.person_id = t2.person_id and t1.visit_source_value = t2.visit_source_value
	inner join cte1 as t3 on t1.person_id = t3.person_id
	WHERE t2.visit_start_date >= t3.observation_period_start_date
	AND t2.visit_end_date <= t3.observation_period_end_date
	ORDER BY t1.person_id, t2.visit_start_date, t2.visit_end_date, t1.visit_source_value
),
cte5 AS (
	SELECT t1.person_id, t1.visit_occurrence_id, MAX(t2.visit_occurrence_id) AS preceding_visit_occurrence_id 
	FROM cte4 AS t1
	INNER JOIN cte4 AS t2 ON t1.person_id = t2.person_id
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
	t1.visit_start_date, 
	t1.visit_start_datetime,
	t1.visit_end_date,
	t1.visit_end_datetime,
	t1.visit_type_concept_id,
	t1.provider_id,
	t1.care_site_id,
	t1.visit_source_value,
	t1.visit_source_concept_id,
	t1.admitting_source_value,
	t1.admitting_source_concept_id,
	t1.discharge_to_source_value,
	t1.discharge_to_concept_id,
	t2.preceding_visit_occurrence_id
	FROM cte4 AS t1
	LEFT JOIN cte5 AS t2 ON t1.visit_occurrence_id = t2.visit_occurrence_id;

DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_vo;

ALTER TABLE {TARGET_SCHEMA}.visit_occurrence ADD CONSTRAINT xpk_visit_occurrence PRIMARY KEY (visit_occurrence_id) USING INDEX TABLESPACE pg_default;
CREATE INDEX idx_visit_occurrence_person_id ON {TARGET_SCHEMA}.visit_occurrence (person_id, visit_start_date) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.visit_occurrence USING idx_visit_occurrence_person_id;
CREATE INDEX idx_visit_concept_id ON {TARGET_SCHEMA}.visit_occurrence (visit_concept_id ASC) TABLESPACE pg_default;
CREATE INDEX idx_visit_source_value ON {TARGET_SCHEMA}.visit_occurrence (visit_source_value ASC) TABLESPACE pg_default;

--------------------------------
-- VISIT_DETAIL from hesae_attendance
--------------------------------
DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_vd;
CREATE SEQUENCE {TARGET_SCHEMA}.sequence_vd INCREMENT 1; 
SELECT setval('{TARGET_SCHEMA}.sequence_vd', (SELECT next_id from {TARGET_SCHEMA}._next_ids WHERE lower(tbl_name) = 'visit_detail'));
 
with cte1 AS (
	SELECT person_id, observation_period_start_date, observation_period_end_date
	FROM {TARGET_SCHEMA}.observation_period
),
cte2 AS (
	SELECT 
	t2.patid AS person_id,
	9203 AS visit_detail_concept_id,
	t2.arrivaldate AS visit_detail_start_date,
	t2.arrivaldate AS visit_detail_start_datetime,
	t2.arrivaldate  AS visit_detail_end_date,
	t2.arrivaldate AS visit_detail_end_datetime,
	32818 AS visit_detail_type_concept_id,
	NULL::int AS provider_id,
	NULL::int AS care_site_id,
	t2.aekey AS visit_detail_source_value,
	NULL::int AS visit_detail_source_concept_id,
	t3.source_code_description AS admitting_source_value,
	t3.target_concept_id AS admitting_source_concept_id,
	NULL::varchar AS discharge_to_source_value,
	NULL::bigint AS discharge_to_concept_id,
	NULL::int AS preceding_visit_detail_id,
	NULL::int AS visit_detail_parent_id,
	NULL::int as visit_occurrence_id
	FROM cte1 as t1	
	INNER JOIN {SOURCE_SCHEMA}.hesae_attendance AS t2 ON t2.patid = t1.person_id
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_concept_map as t3 on t2.aerefsource = t3.source_code::int and t3.source_vocabulary_id = 'HESAE_REFSOURCE_STCM'
),
cte3 AS (
	SELECT person_id, visit_detail_source_value,
	LEAST(visit_detail_start_date, visit_detail_end_date) AS visit_detail_start_date,
	LEAST(visit_detail_start_date, visit_detail_end_date) AS visit_detail_start_datetime,
	GREATEST(visit_detail_start_date, visit_detail_end_date) AS visit_detail_end_date,
	GREATEST(visit_detail_start_date, visit_detail_end_date) AS visit_detail_end_datetime
	FROM cte2
),
cte4 AS (
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
	t1.visit_occurrence_id
	FROM cte2 AS t1
	INNER JOIN cte3 AS t2 ON t1.person_id = t2.person_id AND t1.visit_detail_source_value = t2.visit_detail_source_value
),
cte5 AS (
	SELECT 
	NEXTVAL('{TARGET_SCHEMA}.sequence_vd') AS visit_detail_id, 
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
	INNER JOIN {TARGET_SCHEMA}.visit_occurrence AS t2 ON t2.person_id = t1.person_id AND t2.visit_source_value::bigint = t1.visit_detail_source_value
	INNER JOIN cte1 as t3 ON t1.person_id = t3.person_id
	WHERE t1.visit_detail_start_date >= t3.observation_period_start_date
	AND t1.visit_detail_start_date <= t3.observation_period_end_date
	ORDER BY t1.person_id, t1.visit_detail_start_date, t1.visit_detail_source_value
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

DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_vd;
 
ALTER TABLE {TARGET_SCHEMA}.visit_detail ADD CONSTRAINT xpk_visit_detail PRIMARY KEY (visit_detail_id) USING INDEX TABLESPACE pg_default;	
CREATE INDEX idx_visit_detail_person_id ON {TARGET_SCHEMA}.visit_detail (person_id, visit_detail_source_value) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.visit_detail USING idx_visit_detail_person_id;
CREATE INDEX idx_visit_detail_concept_id ON {TARGET_SCHEMA}.visit_detail (visit_detail_concept_id ASC) TABLESPACE pg_default;
CREATE INDEX idx_visit_detail_occurrence_id ON {TARGET_SCHEMA}.visit_detail (visit_occurrence_id ASC) TABLESPACE pg_default;