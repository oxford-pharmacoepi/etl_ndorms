--------------------------------
-- VISIT_OCCURRENCE
--------------------------------
DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_vo;
CREATE SEQUENCE {TARGET_SCHEMA}.sequence_vo INCREMENT 1;
SELECT setval('{TARGET_SCHEMA}.sequence_vo', (SELECT next_id from {TARGET_SCHEMA}._next_ids WHERE lower(tbl_name) = 'visit_occurrence'));

with cte1 AS (
	SELECT person_id, observation_period_start_date, observation_period_end_date
	FROM {TARGET_SCHEMA}.observation_period
),
cte2 AS (
	SELECT t2.spno, MIN(t2.epistart) AS date_min, MAX(t2.epiend) AS date_max 
	FROM cte1 as t1
	INNER JOIN {SOURCE_SCHEMA}.hes_episodes AS t2 ON t2.patid = t1.person_id
	GROUP BY t2.spno
),
cte3 AS (
	SELECT
	t1.patid AS person_id,
	9201 AS visit_concept_id,
	COALESCE(t1.admidate, t3.date_min, t1.discharged) AS visit_start_date, 
	COALESCE(t1.admidate, t3.date_min, t1.discharged)::timestamp AS visit_start_datetime,
	COALESCE(t1.discharged, t3.date_max, t3.date_min) AS visit_end_date,
	COALESCE(t1.discharged, t3.date_max, t3.date_min)::timestamp AS visit_end_datetime,
	32818 AS visit_type_concept_id,
	NULL::bigint AS provider_id,
	NULL::int AS care_site_id,
	t1.spno AS visit_source_value,
	NULL::int AS visit_source_concept_id,
	t1.admisorc::varchar || '/' || t1.admimeth AS admitted_from_source_value,
	NULL::int AS admitted_from_concept_id,
	t1.disdest::varchar || '/' || t1.dismeth::varchar AS discharged_to_source_value,
	NULL::int AS discharged_to_concept_id,
	NULL::int AS preceding_visit_occurrence_id
	FROM {SOURCE_SCHEMA}.hes_hospital AS t1
	INNER JOIN cte1 as t2 ON t1.patid = t2.person_id
	LEFT JOIN cte2 as t3 ON t1.spno = t3.spno
),
cte4 AS (
	SELECT person_id, visit_source_value,
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
	t1.admitted_from_source_value,
	t1.admitted_from_concept_id,
	t1.discharged_to_source_value,
	t1.discharged_to_concept_id,
	t1.preceding_visit_occurrence_id
	from cte3 as t1
	inner join cte4 as t2 on t1.person_id = t2.person_id and t1.visit_source_value = t2.visit_source_value
	inner join cte1 as t3 on t1.person_id = t3.person_id
	WHERE t2.visit_start_date >= t3.observation_period_start_date
	AND t2.visit_end_date <= t3.observation_period_end_date
	ORDER BY t1.person_id, t2.visit_start_date, t2.visit_end_date, t1.visit_source_value
),
cte6 AS (
	SELECT t1.person_id, t1.visit_occurrence_id, MAX(t2.visit_occurrence_id) AS preceding_visit_occurrence_id 
	FROM cte5 AS t1
	INNER JOIN cte5 AS t2 ON t1.person_id = t2.person_id
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
	admitted_from_source_value,
	admitted_from_concept_id,
	discharged_to_source_value,
	discharged_to_concept_id,
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
	t1.admitted_from_source_value,
	t1.admitted_from_concept_id,
	t1.discharged_to_source_value,
	t1.discharged_to_concept_id,
	t2.preceding_visit_occurrence_id
	FROM cte5 AS t1
	LEFT JOIN cte6 AS t2 ON t1.visit_occurrence_id = t2.visit_occurrence_id;

DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_vo;

ALTER TABLE {TARGET_SCHEMA}.visit_occurrence ADD CONSTRAINT xpk_visit_occurrence PRIMARY KEY (visit_occurrence_id) USING INDEX TABLESPACE pg_default;
CREATE INDEX idx_visit_occurrence_person_id ON {TARGET_SCHEMA}.visit_occurrence (person_id, visit_start_date) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.visit_occurrence USING idx_visit_occurrence_person_id;
CREATE INDEX idx_visit_concept_id ON {TARGET_SCHEMA}.visit_occurrence (visit_concept_id ASC) TABLESPACE pg_default;
CREATE INDEX idx_visit_source_value ON {TARGET_SCHEMA}.visit_occurrence (visit_source_value ASC) TABLESPACE pg_default;

--------------------------------
-- VISIT_DETAIL FROM hes_episodes
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
	t1.patid AS person_id,
	9201 AS visit_detail_concept_id,
	COALESCE(t1.epistart, t1.admidate, t1.epiend) AS visit_detail_start_date,
	COALESCE(t1.epistart, t1.admidate, t1.epiend) AS visit_detail_start_datetime,
	COALESCE(t1.epiend, t1.discharged, t1.epistart) AS visit_detail_end_date,
	COALESCE(t1.epiend, t1.discharged, t1.epistart) AS visit_detail_end_datetime,
	32818 AS visit_detail_type_concept_id,
	NULL::int AS provider_id,
	NULL::int AS care_site_id,
	t1.epikey AS visit_detail_source_value,
	NULL::int AS visit_detail_source_concept_id,
	t1.admisorc::varchar || '/' || t1.admimeth AS admitted_from_source_value,
	NULL::int AS admitted_from_concept_id,
	t1.disdest::varchar || '/' || t1.dismeth::varchar AS discharged_to_source_value,
	NULL::int AS discharged_to_concept_id,
	NULL::int AS preceding_visit_detail_id,
	NULL::int AS parent_visit_detail_id,
	NULL::int as visit_occurrence_id,
	t1.spno
	FROM cte1 as t0 
	INNER JOIN {SOURCE_SCHEMA}.hes_episodes AS t1 ON t1.patid = t0.person_id
),
cte3 AS (
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
	t1.admitted_from_source_value,
	t1.admitted_from_concept_id,	
	t1.discharged_to_source_value,
	t1.discharged_to_concept_id,
	t1.preceding_visit_detail_id,
	t1.parent_visit_detail_id,
	t1.visit_occurrence_id,
	t1.spno
	FROM cte2 AS t1
	INNER JOIN cte3 AS t2 ON t1.person_id = t2.person_id AND t1.visit_detail_source_value = t2.visit_detail_source_value
),
--------------------------------
-- VISIT_DETAIL FROM hes_acp -- TABLE REMOVED
--------------------------------
--cte5 AS (
--	SELECT
--	t1.patid AS person_id,
--	32037 AS visit_detail_concept_id,
--	COALESCE(t1.acpstar,t1.epistart) AS visit_detail_start_date,
--	COALESCE(t1.acpstar,t1.epistart) AS visit_detail_start_datetime,
--	COALESCE(t1.acpend,t1.epiend) AS visit_detail_end_date,
--	COALESCE(t1.acpend,t1.epiend) AS visit_detail_end_datetime,
--	32818 AS visit_detail_type_concept_id,
--	NULL::int AS provider_id,
--	NULL::int AS care_site_id,
--	t1.epikey AS visit_detail_source_value,
--	NULL::int AS visit_detail_source_concept_id,
--	t1.acpsour::varchar AS admitted_from_source_value,
--	NULL::int AS admitted_from_concept_id,
--	t1.acpdisp::varchar AS discharged_to_source_value,
--	NULL::int AS discharged_to_concept_id,
--	NULL::int AS preceding_visit_detail_id,
--	NULL::int AS parent_visit_detail_id,
--	NULL::int AS visit_occurrence_id,
--	t1.spno
--	FROM cte1 as t0 
--	INNER JOIN {SOURCE_SCHEMA}.hes_acp AS t1 ON t1.patid = t0.person_id
--),
cte6 AS (
--------------------------------
-- VISIT_DETAIL FROM hes_ccare
--------------------------------
	SELECT
	patid AS person_id,	
	32037 AS visit_detail_concept_id,
	ccstartdate AS visit_detail_start_date,
	CASE WHEN ccstarttime IS NULL 
		THEN ccstartdate
		ELSE ccstartdate::timestamp + ccstarttime::time 
	END AS visit_detail_start_datetime,
	ccdisdate AS visit_detail_end_date,
	CASE WHEN ccdistime IS NULL
		THEN ccdisdate
		ELSE ccdisdate::timestamp + ccdistime::time 
	END AS visit_detail_end_datetime,
	32818 AS visit_detail_type_concept_id,
	NULL::int AS provider_id,
	NULL::int AS care_site_id,
	epikey AS visit_detail_source_value,
	NULL::int AS visit_detail_source_concept_id,
	t1.ccadmisorc::varchar AS admitted_from_source_value,
	NULL::int AS admitted_from_concept_id,
	t1.ccdisdest::varchar AS discharged_to_source_value,
	NULL::int AS discharged_to_concept_id,
	NULL::int AS preceding_visit_detail_id, 
	NULL::int AS parent_visit_detail_id,
	NULL::int AS visit_occurrence_id,
	t1.spno
	FROM cte1 as t0 
	INNER JOIN {SOURCE_SCHEMA}.hes_ccare AS t1 ON t1.patid = t0.person_id
),
cte7 AS (
	SELECT * FROM cte4
--	UNION ALL
--	SELECT * FROM cte5
	UNION ALL
	SELECT * FROM cte6
),
cte8 AS (
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
	t1.admitted_from_source_value,
	t1.admitted_from_concept_id,
	t1.discharged_to_source_value,
	t1.discharged_to_concept_id,
	t1.preceding_visit_detail_id, 
	t1.parent_visit_detail_id,
	t2.visit_occurrence_id
	FROM cte7 as t1
	INNER JOIN {TARGET_SCHEMA}.visit_occurrence AS t2 ON t2.visit_source_value::bigint = t1.spno and t2.person_id = t1.person_id
	INNER JOIN cte1 as t3 ON t1.person_id = t3.person_id
	WHERE t1.visit_detail_start_date >= t3.observation_period_start_date
	AND t1.visit_detail_start_date <= t3.observation_period_end_date
	ORDER BY t1.person_id, t1.visit_detail_start_date, t1.visit_detail_source_value
),
cte9 AS (
	SELECT t1.person_id, t1.visit_detail_id, MAX(t2.visit_detail_id) AS preceding_visit_detail_id 
	FROM cte8 AS t1
	INNER JOIN cte8 AS t2 ON t1.person_id = t2.person_id
	WHERE t1.visit_detail_id > t2.visit_detail_id
	GROUP BY t1.person_id, t1.visit_detail_id
),
cte10 AS (
	SELECT distinct t1.patid, t1.epikey, t2.provider_id
	FROM cte1 as t0 
	INNER JOIN {SOURCE_SCHEMA}.hes_episodes as t1 ON t1.patid = t0.person_id
	INNER JOIN {TARGET_SCHEMA}.provider AS t2 ON t1.pconsult = t2.provider_source_value 
	INNER JOIN {VOCABULARY_SCHEMA}.source_to_concept_map as t3 ON CASE WHEN t1.tretspef <> '&' THEN t1.tretspef ELSE CASE WHEN t1.mainspef <> '&' THEN t1.mainspef ELSE Null END END = t3.source_code 
	and t3.source_vocabulary_id = 'HES_SPEC_STCM'
	WHERE t3.source_code_description = t2.specialty_source_value
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
	admitted_from_source_value,
	admitted_from_concept_id,
	discharged_to_source_value,
	discharged_to_concept_id,
	preceding_visit_detail_id,
	parent_visit_detail_id,
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
	t3.provider_id,
	t1.care_site_id,
	t1.visit_detail_source_value,
	t1.visit_detail_source_concept_id,
	t1.admitted_from_source_value,
	t1.admitted_from_concept_id,
	t1.discharged_to_source_value,
	t1.discharged_to_concept_id,
	t2.preceding_visit_detail_id,
	t1.parent_visit_detail_id,
	t1.visit_occurrence_id
FROM cte8 as t1
LEFT JOIN cte9 AS t2 ON t1.visit_detail_id = t2.visit_detail_id
LEFT JOIN cte10 AS t3 ON t1.person_id = t3.patid and t1.visit_detail_source_value::bigint = t3.epikey;

DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_vd;

ALTER TABLE {TARGET_SCHEMA}.visit_detail ADD CONSTRAINT xpk_visit_detail PRIMARY KEY (visit_detail_id) USING INDEX TABLESPACE pg_default;	
CREATE INDEX idx_visit_detail_person_id  ON {TARGET_SCHEMA}.visit_detail (person_id, visit_detail_source_value) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.visit_detail USING idx_visit_detail_person_id;
CREATE INDEX idx_visit_detail_concept_id ON {TARGET_SCHEMA}.visit_detail (visit_detail_concept_id ASC) TABLESPACE pg_default;
CREATE INDEX idx_visit_detail_occurrence_id ON {TARGET_SCHEMA}.visit_detail (visit_occurrence_id ASC) TABLESPACE pg_default;