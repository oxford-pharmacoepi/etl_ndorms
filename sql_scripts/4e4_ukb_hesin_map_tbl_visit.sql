--------------------------------
-- VISIT_OCCURRENCE
--------------------------------
DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_vo;
CREATE SEQUENCE {TARGET_SCHEMA}.sequence_vo INCREMENT 1;
SELECT setval('{TARGET_SCHEMA}.sequence_vo', COALESCE((SELECT max_id from {TARGET_SCHEMA_TO_LINK}._max_ids WHERE lower(tbl_name) = 'visit_occurrence'), 1));

with cte1 AS (
	SELECT person_id, observation_period_start_date, observation_period_end_date
	FROM {TARGET_SCHEMA}.observation_period
),
cte2 AS (
	SELECT t2.eid,t2.ins_index, MIN(t2.epistart) AS date_min, MAX(t2.epiend) AS date_max 
	FROM cte1 as t1
	INNER JOIN {SOURCE_SCHEMA}.hesin AS t2 ON t2.eid = t1.person_id
	GROUP BY t2.eid,t2.ins_index
),
cte3 AS (
	SELECT
	--NEXTVAL('{TARGET_SCHEMA}.sequence_vo') AS visit_occurrence_id,
	t1.eid AS person_id,
	9201 AS visit_concept_id,
	COALESCE(t1.admidate, t2.date_min, t1.disdate) AS visit_start_date, 
	COALESCE(t1.admidate, t2.date_min, t1.disdate) AS visit_start_datetime,
	COALESCE(t1.disdate, t2.date_max, t2.date_min) AS visit_end_date,
	COALESCE(t1.disdate, t2.date_max, t2.date_min) AS visit_end_datetime,
	32818 AS visit_type_concept_id,
	NULL::bigint AS provider_id,
	NULL::int AS care_site_id,
	t1.ins_index AS visit_source_value,
	NULL::int AS visit_source_concept_id,
	t4.source_code_description AS admitted_from_source_value,
	t4.target_concept_id AS admitted_from_concept_id,
	NULL AS discharged_to_source_value,
	NULL::int AS discharged_to_concept_id,
	NULL::int AS preceding_visit_occurrence_id
	FROM {SOURCE_SCHEMA}.hesin AS t1
	INNER JOIN cte2 as t2 ON t1.eid = t2.eid and t1.ins_index = t2.ins_index
	INNER JOIN cte1 as t3 ON t2.eid = t3.person_id
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t4.source_code = CONCAT('264-',t1.admimeth_uni) and t4.target_domain_id = 'visit' and t4.source_vocabulary_id = 'UKB_ADMIMETH_STCM'
),
cte4 AS (
	SELECT person_id,visit_source_value,
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

ALTER TABLE {TARGET_SCHEMA}.visit_occurrence ADD CONSTRAINT xpk_visit_occurrence PRIMARY KEY (visit_occurrence_id);
CREATE INDEX idx_visit_occurrence_person_id ON {TARGET_SCHEMA}.visit_occurrence (person_id, visit_start_date);
CLUSTER {TARGET_SCHEMA}.visit_occurrence USING idx_visit_occurrence_person_id;
CREATE INDEX idx_visit_concept_id ON {TARGET_SCHEMA}.visit_occurrence (visit_concept_id ASC);
CREATE INDEX idx_visit_source_value ON {TARGET_SCHEMA}.visit_occurrence (visit_source_value ASC);

--------------------------------
-- VISIT_DETAIL FROM hesin_critical
--------------------------------
DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_vd;
CREATE SEQUENCE {TARGET_SCHEMA}.sequence_vd INCREMENT 1; 
SELECT setval('{TARGET_SCHEMA}.sequence_vd', COALESCE((SELECT max_id from {TARGET_SCHEMA_TO_LINK}._max_ids WHERE lower(tbl_name) = 'visit_detail'), 1));

with cte1 AS (
	SELECT person_id, observation_period_start_date, observation_period_end_date
	FROM {TARGET_SCHEMA}.observation_period
),
cte2 AS (
	SELECT 
	t1.eid AS person_id,
	9201 AS visit_detail_concept_id,
	COALESCE(t1.ccstartdate, t1.ccdisdate) AS visit_detail_start_date,
	COALESCE(t1.ccstartdate, t1.ccdisdate) AS visit_detail_start_datetime,
	COALESCE(t1.ccdisdate, t1.ccstartdate) AS visit_detail_end_date,
	COALESCE(t1.ccdisdate, t1.ccstartdate) AS visit_detail_end_datetime,
	32818 AS visit_detail_type_concept_id,
	NULL::int AS provider_id,
	NULL::int AS care_site_id,
	t1.ins_index AS visit_detail_source_value,
	NULL::int AS visit_detail_source_concept_id,
	t2.source_code_description AS admitted_from_source_value,
	t2.target_concept_id AS admitted_from_concept_id,
	NULL AS discharged_to_source_value,
	NULL::int AS discharged_to_concept_id,
	NULL::int AS preceding_visit_detail_id,
	NULL::int AS parent_visit_detail_id,
	NULL::int as visit_occurrence_id,
	t1.arr_index AS arr_index
	FROM cte1 as t0 
	INNER JOIN {SOURCE_SCHEMA}.hesin_critical AS t1 ON t1.eid = t0.person_id
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_concept_map as t2 on CONCAT('7004-',t1.ccadmisorc)  = t2.source_code and t2.source_vocabulary_id = 'UKB_CCADMISORC_STCM'
),
cte3 AS (
	SELECT person_id, visit_detail_source_value,arr_index,
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
    NEXTVAL('{TARGET_SCHEMA}.sequence_vd') AS visit_detail_id,	
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
	t3.visit_occurrence_id
	FROM cte2 AS t1
	INNER JOIN cte3 AS t2 ON t1.person_id = t2.person_id 
	AND t1.visit_detail_source_value = t2.visit_detail_source_value AND t1.arr_index = t2.arr_index
	INNER JOIN {TARGET_SCHEMA}.visit_occurrence AS t3 ON CAST(t1.visit_detail_source_value AS INT) = CAST(t3.visit_source_value AS INT) and t3.person_id = t1.person_id
),
--------------------------------
-- VISIT_DETAIL FROM hesin_psych
--------------------------------
cte5 AS (
	SELECT
	t1.eid AS person_id,
	9201 AS visit_detail_concept_id,
	t1.detndate::date AS visit_detail_start_date,
	t1.detndate::timestamp AS visit_detail_start_datetime,
	NULL::date AS visit_detail_end_date,
	NULL::timestamp AS visit_detail_end_datetime,
	32818 AS visit_detail_type_concept_id,
	NULL::int AS provider_id,
	NULL::int AS care_site_id,
	t1.ins_index AS visit_detail_source_value,
	NULL::int AS visit_detail_source_concept_id,
	NULL::varchar AS admitted_from_source_value,
	NULL::int AS admitted_from_concept_id,
	NULL::varchar  AS discharged_to_source_value,
	NULL::int AS discharged_to_concept_id,
	NULL::int AS preceding_visit_detail_id,
	NULL::int AS parent_visit_detail_id,
	NULL::int AS visit_occurrence_id
	FROM cte1 as t0 
	INNER JOIN {SOURCE_SCHEMA}.hesin_psych AS t1 ON t1.eid = t0.person_id
),
cte6 AS (
	SELECT 
	NEXTVAL('{TARGET_SCHEMA}.sequence_vd') AS visit_detail_id, 
	t1.person_id,	
	t1.visit_detail_concept_id,
	CASE 
        WHEN t1.visit_detail_start_date IS NULL THEN COALESCE(t3.epistart::date, t3.admidate::date,t3.disdate::date) 
        ELSE t1.visit_detail_start_date
    END AS visit_detail_start_date,
	CASE 
        WHEN t1.visit_detail_start_datetime IS NULL THEN COALESCE(t3.epistart::timestamp, t3.admidate::timestamp,t3.disdate::timestamp) 
        ELSE t1.visit_detail_start_datetime
    END AS visit_detail_start_datetime,	
	
    CASE 
        WHEN t1.visit_detail_end_date IS NULL THEN COALESCE(t3.epiend::date, t3.admidate::date,t3.epistart::date)
        ELSE t1.visit_detail_end_date
    END AS visit_detail_end_date,

    CASE 
        WHEN t1.visit_detail_end_datetime IS NULL THEN COALESCE(t3.epiend::timestamp, t3.admidate::timestamp,t3.epistart::timestamp)
        ELSE t1.visit_detail_end_datetime
    END AS visit_detail_end_datetime,	
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
	FROM cte5 as t1
	LEFT JOIN {TARGET_SCHEMA}.visit_occurrence AS t2 ON t1.visit_detail_source_value::int = t2.visit_source_value::int and t2.person_id = t1.person_id
	INNER JOIN  {SOURCE_SCHEMA}.hesin as t3 ON t1.person_id = t3.eid and t1.visit_detail_source_value = t3.ins_index
	ORDER BY t1.person_id, t1.visit_detail_start_date, t1.visit_detail_source_value
),
cte7 AS (
	SELECT t1.person_id, t1.visit_detail_id, MAX(t2.visit_detail_id) AS preceding_visit_detail_id 
	FROM cte6 AS t1
	INNER JOIN cte6 AS t2 ON t1.person_id = t2.person_id
	WHERE t1.visit_detail_id > t2.visit_detail_id
	GROUP BY t1.person_id,t1.visit_detail_id
),
cte8 AS (
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
	t1.admitted_from_source_value,
	t1.admitted_from_concept_id,
	t1.discharged_to_source_value,
	t1.discharged_to_concept_id,
	t2.preceding_visit_detail_id,
	t1.parent_visit_detail_id,
	t1.visit_occurrence_id
FROM cte6 as t1
LEFT JOIN cte7 AS t2 ON t1.visit_detail_id = t2.visit_detail_id
), 
cte9 AS(
	select * from cte4
	union 
	select * from cte8
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
	t1.visit_occurrence_id
FROM cte9 as t1
	WHERE 
		t1.visit_detail_start_date IS NOT NULL AND 
		t1.visit_detail_end_date IS NOT NULL;


DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_vd;

ALTER TABLE {TARGET_SCHEMA}.visit_detail ADD CONSTRAINT xpk_visit_detail PRIMARY KEY (visit_detail_id);	
CREATE INDEX idx_visit_detail_person_id  ON {TARGET_SCHEMA}.visit_detail (person_id, visit_detail_source_value);
CLUSTER {TARGET_SCHEMA}.visit_detail USING idx_visit_detail_person_id;
CREATE INDEX idx_visit_detail_concept_id ON {TARGET_SCHEMA}.visit_detail (visit_detail_concept_id ASC);
CREATE INDEX idx_visit_detail_occurrence_id ON {TARGET_SCHEMA}.visit_detail (visit_occurrence_id ASC);