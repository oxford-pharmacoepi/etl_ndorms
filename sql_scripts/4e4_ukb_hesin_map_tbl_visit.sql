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
	select t1.person_id, t2.ins_index,
	CASE WHEN t2.tretspef <> '&' THEN t2.tretspef ELSE CASE WHEN t2.mainspef <> '&' THEN t2.mainspef ELSE Null END END as specialty
	FROM cte1 as t1
	INNER JOIN {SOURCE_SCHEMA}.hesin AS t2 on t1.person_id = t2.eid
),	
cte3 AS (	
	select t1.person_id, t1.ins_index, t3.provider_id
	FROM cte2 as t1
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_concept_map as t2 on t1.specialty = t2.source_code 
	and t2.source_vocabulary_id = 'HES_SPEC_STCM'
	LEFT JOIN {TARGET_SCHEMA}.provider as t3 on t3.specialty_source_value = t2.source_code_description
),
cte4 AS (
	SELECT t2.eid,t2.spell_index, MIN(t2.epistart) AS date_min, MAX(t2.epiend) AS date_max 
	FROM cte1 as t1
	INNER JOIN {SOURCE_SCHEMA}.hesin AS t2 ON t2.eid = t1.person_id
	GROUP BY t2.eid,t2.spell_index
),
cte5 AS (
	SELECT
	t1.eid AS person_id,
	9201 AS visit_concept_id,
	COALESCE(t2.date_min,t1.admidate, t1.disdate) AS visit_start_date, 
	COALESCE(t2.date_min,t1.admidate, t1.disdate) AS visit_start_datetime,
	COALESCE(t2.date_max,t2.date_min,t1.disdate) AS visit_end_date,
	COALESCE(t2.date_max,t2.date_min,t1.disdate) AS visit_end_datetime,
	32818 AS visit_type_concept_id,
	t3.provider_id AS provider_id,
	NULL::int AS care_site_id,
	t1.spell_index AS visit_source_value,
	NULL::int AS visit_source_concept_id,
	t4.source_code_description AS admitted_from_source_value,
	t4.target_concept_id AS admitted_from_concept_id,
	t5.source_code_description AS discharged_to_source_value,
	t5.target_concept_id::int AS discharged_to_concept_id,
	NULL::int AS preceding_visit_occurrence_id
	FROM {SOURCE_SCHEMA}.hesin AS t1
	INNER JOIN cte4 as t2 ON t1.eid = t2.eid AND t1.spell_index = t2.spell_index
	INNER JOIN cte3 as t3 ON t1.eid = t3.person_id AND t1.ins_index = t3.ins_index
	LEFT JOIN {TARGET_SCHEMA}.source_to_standard_vocab_map as t4 on t4.source_code = CONCAT('265-',t1.admisorc_uni) and t4.target_domain_id = 'Visit' and t4.source_vocabulary_id = 'UKB_ADMISORC_STCM'
	LEFT JOIN {TARGET_SCHEMA}.source_to_standard_vocab_map as t5 on t5.source_code = CONCAT('267-',t1.disdest_uni) and t5.target_domain_id = 'Visit' and t5.source_vocabulary_id = 'UKB_DISDEST_STCM'
	WHERE t1.spell_seq = 0
),
cte6 AS (
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
	FROM cte5
),
cte7 AS (
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
	from cte5 as t1
	inner join cte6 as t2 on t1.person_id = t2.person_id and t1.visit_source_value = t2.visit_source_value
	inner join cte1 as t3 on t1.person_id = t3.person_id
	WHERE t2.visit_start_date >= t3.observation_period_start_date
	AND t2.visit_end_date <= t3.observation_period_end_date
	ORDER BY t1.person_id, t2.visit_start_date, t2.visit_end_date, t1.visit_source_value
),
cte8 AS (
	SELECT t1.person_id, t1.visit_occurrence_id,MAX(t2.visit_occurrence_id) AS preceding_visit_occurrence_id 
	FROM cte7 AS t1
	INNER JOIN cte7 AS t2 ON t1.person_id = t2.person_id
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
	FROM cte7 AS t1
	LEFT JOIN cte8 AS t2 ON t1.visit_occurrence_id = t2.visit_occurrence_id;

DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_vo;

ALTER TABLE {TARGET_SCHEMA}.visit_occurrence ADD CONSTRAINT xpk_visit_occurrence PRIMARY KEY (visit_occurrence_id) USING INDEX TABLESPACE pg_default;
CREATE INDEX idx_visit_occ1 ON {TARGET_SCHEMA}.visit_occurrence (person_id, visit_start_date) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.visit_occurrence USING idx_visit_occ1;
CREATE INDEX idx_visit_concept_id ON {TARGET_SCHEMA}.visit_occurrence (visit_concept_id ASC) TABLESPACE pg_default;
CREATE INDEX idx_visit_source_value ON {TARGET_SCHEMA}.visit_occurrence (visit_source_value ASC) TABLESPACE pg_default;

---------------------------------
-- VISIT_DETAIL FROM hesin
--------------------------------
DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_vd;
CREATE SEQUENCE {TARGET_SCHEMA}.sequence_vd INCREMENT 1; 
SELECT setval('{TARGET_SCHEMA}.sequence_vd', (SELECT max_id from {TARGET_SCHEMA_TO_LINK}._max_ids WHERE lower(tbl_name) = 'visit_detail'));

with cte0 AS (
	SELECT person_id, observation_period_start_date, observation_period_end_date
	FROM {TARGET_SCHEMA}.observation_period
),
cte1 AS (
	SELECT
	t1.eid AS person_id,
	9201 AS visit_detail_concept_id,
	COALESCE(t1.epistart::date,t1.admidate::date, t1.disdate::date) AS visit_detail_start_date,
	COALESCE(t1.epistart::timestamp,t1.admidate::timestamp, t1.disdate::timestamp) AS visit_detail_start_datetime,
	COALESCE(t1.epiend::date,t1.epistart::date, t1.disdate::date) AS visit_detail_end_date,
	COALESCE(t1.epiend::timestamp,t1.epistart::timestamp,t1.disdate::timestamp) AS visit_detail_end_datetime,
	32818 AS visit_detail_type_concept_id,
	NULL::int AS provider_id,
	NULL::int AS care_site_id,
	t1.ins_index AS visit_detail_source_value,
	NULL::int AS visit_detail_source_concept_id,
	t4.source_code_description AS admitted_from_source_value,
	t4.target_concept_id AS admitted_from_concept_id,
	t5.source_code_description AS discharged_to_source_value,
	t5.target_concept_id::int AS discharged_to_concept_id,
	NULL::int AS preceding_visit_detail_id,
	NULL::int AS parent_visit_detail_id,
	NULL::int as visit_occurrence_id,
	t1.spell_index AS spell_index,
	t1.spell_seq AS spell_seq
	FROM cte0 as t0 
	INNER JOIN {SOURCE_SCHEMA}.hesin AS t1 ON t1.eid = t0.person_id
	LEFT JOIN {TARGET_SCHEMA}.source_to_standard_vocab_map as t4 on t4.source_code = CONCAT('265-',t1.admisorc_uni) and t4.target_domain_id = 'Visit' and t4.source_vocabulary_id = 'UKB_ADMISORC_STCM'
	LEFT JOIN {TARGET_SCHEMA}.source_to_standard_vocab_map as t5 on t5.source_code = CONCAT('267-',t1.disdest_uni) and t5.target_domain_id = 'Visit' and t5.source_vocabulary_id = 'UKB_DISDEST_STCM'
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
	t1.admitted_from_source_value,
	t1.admitted_from_concept_id,	
	t1.discharged_to_source_value,
	t1.discharged_to_concept_id,
	t1.preceding_visit_detail_id,
	t1.parent_visit_detail_id,
	t1.visit_occurrence_id,
	t1.spell_index,
	t1.spell_seq
	FROM cte1 AS t1
	INNER JOIN cte2 AS t2 ON t1.person_id = t2.person_id AND t1.visit_detail_source_value = t2.visit_detail_source_value
),
--------------------------------
-- VISIT_DETAIL FROM hesin_psych
--------------------------------
cte4 AS (
	SELECT
	t1.eid AS person_id,
	9201 AS visit_detail_concept_id,
	COALESCE(t1.epistart::date,t1.admidate::date,t2.detndate::date, t1.disdate::date) AS visit_detail_start_date,
	COALESCE(t1.epistart::timestamp,t1.admidate::timestamp,t2.detndate::timestamp, t1.disdate::timestamp) AS visit_detail_start_datetime,
	COALESCE(t1.epiend::date,t1.epistart::date, t1.disdate::date,t2.detndate::date) AS visit_detail_end_date,
	COALESCE(t1.epiend::timestamp,t1.epistart::timestamp,t1.disdate::timestamp,t2.detndate::timestamp) AS visit_detail_end_datetime,
	32818 AS visit_detail_type_concept_id,
	NULL::int AS provider_id,
	NULL::int AS care_site_id,
	t1.ins_index AS visit_detail_source_value,
	NULL::int AS visit_detail_source_concept_id,
	t4.source_code_description AS admitted_from_source_value,
	t4.target_concept_id AS admitted_from_concept_id,
	t5.source_code_description AS discharged_to_source_value,
	t5.target_concept_id::int AS discharged_to_concept_id,
	NULL::int AS preceding_visit_detail_id,
	NULL::int AS parent_visit_detail_id,
	NULL::int AS visit_occurrence_id,
	t1.spell_index AS spell_index,
	t1.spell_seq as spell_seq
	FROM cte0 as t0 
	INNER JOIN {SOURCE_SCHEMA}.hesin as t1 on t1.eid = t0.person_id 
	INNER JOIN {SOURCE_SCHEMA}.hesin_psych AS t2 ON t1.eid = t2.eid AND t1.ins_index = t2.ins_index
	LEFT JOIN {TARGET_SCHEMA}.source_to_standard_vocab_map as t4 on t4.source_code = CONCAT('265-',t1.admisorc_uni) and t4.target_domain_id = 'Visit' and t4.source_vocabulary_id = 'UKB_ADMISORC_STCM'
	LEFT JOIN {TARGET_SCHEMA}.source_to_standard_vocab_map as t5 on t5.source_code = CONCAT('267-',t1.disdest_uni) and t5.target_domain_id = 'Visit' and t5.source_vocabulary_id = 'UKB_DISDEST_STCM'
),
cte5 AS (
--------------------------------
-- VISIT_DETAIL FROM hesin_critical
--------------------------------
	SELECT 
	t1.eid AS person_id,
	9201 AS visit_detail_concept_id,
	COALESCE(t1.epistart::date,t1.admidate::date,t2.ccstartdate::date, t1.disdate::date) AS visit_detail_start_date,
	COALESCE(t1.epistart::timestamp,t1.admidate::timestamp,t2.ccstartdate::timestamp,t1.disdate::timestamp) AS visit_detail_start_datetime,
	COALESCE(t1.epiend::date,t1.epistart::date, t2.ccdisdate::timestamp,t1.disdate::date) AS visit_detail_end_date,
	COALESCE(t1.epiend::timestamp,t1.epistart::timestamp,t2.ccdisdate::timestamp,t1.disdate::timestamp) AS visit_detail_end_datetime,
	32818 AS visit_detail_type_concept_id,
	NULL::int AS provider_id,
	NULL::int AS care_site_id,
	t1.ins_index AS visit_detail_source_value,
	NULL::int AS visit_detail_source_concept_id,
	t4.source_code_description AS admitted_from_source_value,
	t4.target_concept_id AS admitted_from_concept_id,
	t5.source_code_description AS discharged_to_source_value,
	t5.target_concept_id::int AS discharged_to_concept_id,
	NULL::int AS preceding_visit_detail_id,
	NULL::int AS parent_visit_detail_id,
	NULL::int as visit_occurrence_id,
	t1.spell_index AS spell_index,
	t1.spell_seq AS spell_seq
	FROM cte0 as t0 
	INNER JOIN {SOURCE_SCHEMA}.hesin as t1 on t1.eid = t0.person_id
	INNER JOIN {SOURCE_SCHEMA}.hesin_critical AS t2 ON t1.eid = t2.eid AND t1.ins_index = t2.ins_index 
	LEFT JOIN {TARGET_SCHEMA}.source_to_standard_vocab_map as t4 on t4.source_code = CONCAT('265-',t1.admisorc_uni) and t4.target_domain_id = 'Visit' and t4.source_vocabulary_id = 'UKB_ADMISORC_STCM'
	LEFT JOIN {TARGET_SCHEMA}.source_to_standard_vocab_map as t5 on t5.source_code = CONCAT('267-',t1.disdest_uni) and t5.target_domain_id = 'Visit' and t5.source_vocabulary_id = 'UKB_DISDEST_STCM'
),
cte6 AS (
	SELECT * FROM cte3
	UNION
	SELECT * FROM cte4
	UNION
	SELECT * FROM cte5
),
cte7 AS (
	SELECT 
	NEXTVAL('{TARGET_SCHEMA}.sequence_vd') AS visit_detail_id, 
	t1.person_id,	
	t1.visit_detail_concept_id,
	t1.visit_detail_start_date,
	t1.visit_detail_start_datetime,
	t1.visit_detail_end_date,
	t1.visit_detail_end_datetime,
	t1.visit_detail_type_concept_id,
	t2.provider_id,
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
	FROM cte6 as t1
	INNER JOIN {TARGET_SCHEMA}.visit_occurrence AS t2 ON t2.visit_source_value::bigint = t1.spell_index and t2.person_id = t1.person_id
	INNER JOIN cte0 as t3 ON t1.person_id = t3.person_id
	WHERE t1.visit_detail_start_date >= t3.observation_period_start_date
	AND t1.visit_detail_start_date <= t3.observation_period_end_date
	ORDER BY t1.person_id, t1.spell_index,t1.spell_seq
),
cte8 AS (
	SELECT t1.person_id, t1.visit_detail_id, MAX(t2.visit_detail_id) AS preceding_visit_detail_id 
	FROM cte7 AS t1
	INNER JOIN cte7 AS t2 ON t1.person_id = t2.person_id
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
	t2.preceding_visit_detail_id,
	t1.parent_visit_detail_id,
	t1.visit_occurrence_id
FROM cte7 as t1
LEFT JOIN cte8 AS t2 ON t1.visit_detail_id = t2.visit_detail_id;

DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_vd;

ALTER TABLE {TARGET_SCHEMA}.visit_detail ADD CONSTRAINT xpk_visit_detail PRIMARY KEY (visit_detail_id) USING INDEX TABLESPACE pg_default;	
CREATE INDEX idx_visit_detail_person_id  ON {TARGET_SCHEMA}.visit_detail (person_id, visit_detail_source_value) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.visit_detail USING idx_visit_detail_person_id;
CREATE INDEX idx_visit_detail_concept_id ON {TARGET_SCHEMA}.visit_detail (visit_detail_concept_id ASC) TABLESPACE pg_default;
CREATE INDEX idx_visit_det_occ_id ON {TARGET_SCHEMA}.visit_detail (visit_occurrence_id ASC) TABLESPACE pg_default;