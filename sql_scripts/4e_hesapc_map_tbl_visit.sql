--------------------------------
-- VISIT_OCCURRENCE
--------------------------------
DROP SEQUENCE IF EXISTS sequence_vo;
CREATE SEQUENCE sequence_vo INCREMENT 1;
SELECT setval('sequence_vo', (SELECT COALESCE(public_records,0) FROM public._records WHERE lower(tbl_name) = 'visit_occurrence'));

with cte1 AS (
	SELECT person_id
	FROM {TARGET_SCHEMA}.person
),
cte2 AS (
	SELECT t2.spno, MIN(t2.epistart) AS date_min, MAX(t2.epiend) AS date_max 
	FROM cte1 as t1
	INNER JOIN {SOURCE_SCHEMA}.hes_episodes AS t2 ON t2.patid = t1.person_id
	GROUP BY t2.spno
),
cte3 AS (
	SELECT
	NEXTVAL('sequence_vo') AS visit_occurrence_id,
	t1.patid AS person_id,
	9201 AS visit_concept_id,
	COALESCE(admidate, t3.date_min, discharged) AS visit_start_date, 
	COALESCE(admidate, t3.date_min, discharged) AS visit_start_datetime,
	COALESCE(discharged, t3.date_max, t3.date_min) AS visit_end_date,
	COALESCE(discharged, t3.date_max, t3.date_min) AS visit_end_datetime,
	32818 AS visit_type_concept_id,
	NULL::bigint AS provider_id,
	NULL::int AS care_site_id,
	t1.spno AS visit_source_value,
	NULL::int AS visit_source_concept_id,
	t4.source_code_description AS admitting_source_value,
	t4.target_concept_id AS admitting_source_concept_id,
	t5.source_code_description AS discharge_to_source_value,
	t5.target_concept_id AS discharge_to_concept_id,
	NULL::int AS preceding_visit_occurrence_id
	FROM {SOURCE_SCHEMA}.hes_hospital AS t1
	INNER JOIN cte1 as t2 ON t1.patid = t2.person_id
	LEFT JOIN cte2 as t3 ON t1.spno = t3.spno
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.admimeth = t4.source_code and t4.source_vocabulary_id = 'HESAPC_ADMIMETH_STCM'
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t5 on t1.dismeth::varchar = t5.source_code and t5.source_vocabulary_id = 'HESAPC_DISMETH_STCM'
	ORDER BY patid, COALESCE(admidate, t3.date_min, discharged), COALESCE(discharged, t3.date_max, t3.date_min)
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
SELECT setval('sequence_vd', (SELECT COALESCE(public_records,0) FROM public._records WHERE lower(tbl_name) = 'visit_detail'));

WITH cte1 AS (
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
	t2.source_code_description AS admitting_source_value,	-- ANTO: definition to be added instead of number
	t2.target_concept_id AS admitting_source_concept_id,				-- ANTO: to be implemented FROM admimeth
	t3.source_code_description AS discharge_to_source_value,		-- ANTO: definition to be added instead of number
	t3.target_concept_id AS discharge_to_concept_id,			-- ANTO: to be implemented FROM dismeth
	NULL::int AS preceding_visit_detail_id, 					-- ANTO: to be filled in later when the table is all filled in
	NULL::int AS visit_detail_parent_id,
	NULL::int as visit_occurrence_id,
	t1.spno
	FROM {SOURCE_SCHEMA}.hes_episodes AS t1
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_concept_map as t2 on t1.admimeth = t2.source_code and t2.source_vocabulary_id = 'HESAPC_ADMIMETH_STCM'
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_concept_map as t3 on t1.dismeth::varchar = t3.source_code and t3.source_vocabulary_id = 'HESAPC_DISMETH_STCM'

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
	t1.spno
	FROM cte1 AS t1
	INNER JOIN cte2 AS t2 ON t1.person_id = t2.person_id AND t1.visit_detail_source_value = t2.visit_detail_source_value
),
--------------------------------
-- VISIT_DETAIL FROM hes_acp
--------------------------------
cte4 AS (
	SELECT
	t1.patid AS person_id,
	32037 AS visit_detail_concept_id,
	COALESCE(t1.acpstar,t1.epistart) AS visit_detail_start_date,
	COALESCE(t1.acpstar,t1.epistart) AS visit_detail_start_datetime,
	COALESCE(t1.acpend,t1.epiend) AS visit_detail_end_date,
	COALESCE(t1.acpend,t1.epiend) AS visit_detail_end_datetime,
	32818 AS visit_detail_type_concept_id,
	NULL::int AS provider_id,
	NULL::int AS care_site_id,
	t1.epikey AS visit_detail_source_value,
	NULL::int AS visit_detail_source_concept_id,
	t2.source_code_description AS admitting_source_value,	 		-- ANTO: definition to be added instead of number
	t2.target_concept_id AS admitting_source_concept_id, 			-- ANTO: to be implemented FROM admimeth
	t3.source_code_description AS discharge_to_source_value,		-- ANTO: definition to be added instead of number
	t3.target_concept_id AS discharge_to_concept_id,	 			-- ANTO: to be implemented FROM dismeth
	NULL::int AS preceding_visit_detail_id, 						-- to be filled in later
	NULL::int AS visit_detail_parent_id,							-- to be filled in later
	NULL::int AS visit_occurrence_id,
	t1.spno
	FROM {SOURCE_SCHEMA}.hes_acp AS t1
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_concept_map as t2 on t1.acpsour::varchar = t2.source_code and t2.source_vocabulary_id = 'HESAPC_ACPSOUR_STCM'
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_concept_map as t3 on t1.acpdisp::varchar = t3.source_code and t3.source_vocabulary_id = 'HESAPC_ACPDISP_STCM'
),
cte5 AS (
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
	t2.source_code_description AS admitting_source_value,
	t2.target_concept_id AS admitting_source_concept_id,
	t3.source_code_description AS discharge_to_source_value,
	t3.target_concept_id AS discharge_to_concept_id,
	NULL::int AS preceding_visit_detail_id, 
	NULL::int AS visit_detail_parent_id,
	NULL::int AS visit_occurrence_id,
	t1.spno
	FROM {SOURCE_SCHEMA}.hes_ccare AS t1
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_concept_map as t2 on t1.ccadmisorc::varchar = t2.source_code and t2.source_vocabulary_id = 'HESAPC_ADMISORC_STCM'
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_concept_map as t3 on t1.ccdisdest::varchar = t3.source_code and t3.source_vocabulary_id = 'HESAPC_DISDEST_STCM'
),
cte6 AS (
	SELECT * FROM cte3
	UNION ALL
	SELECT * FROM cte4
	UNION ALL
	SELECT * FROM cte5
	ORDER BY person_id, visit_detail_source_value, visit_detail_start_datetime
),
cte7 AS (
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
	FROM cte6 as t1
	INNER JOIN {TARGET_SCHEMA}.visit_occurrence AS t2 ON t2.visit_source_value::bigint = t1.spno
),
cte8 AS (
	SELECT t1.person_id, t1.visit_detail_id, MAX(t2.visit_detail_id) AS preceding_visit_detail_id 
	FROM cte7 AS t1
	INNER JOIN cte7 AS t2 ON t1.person_id = t2.person_id
	WHERE t1.visit_detail_id > t2.visit_detail_id
	GROUP BY t1.person_id, t1.visit_detail_id
),
cte9 AS (
	SELECT distinct patid, epikey, provider_id
	FROM {SOURCE_SCHEMA}.hes_episodes as t1
	INNER JOIN {TARGET_SCHEMA}.provider AS t2 ON t1.pconsult = t2.provider_source_value 
	WHERE t1.tretspef = t2.specialty_source_value
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
	t3.provider_id,
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
FROM cte7 as t1
LEFT JOIN cte8 AS t2 ON t1.visit_detail_id = t2.visit_detail_id
LEFT JOIN cte9 AS t3 ON t1.person_id = t3.patid and t1.visit_detail_source_value::bigint = t3.epikey;

DROP SEQUENCE IF EXISTS sequence_vd;

ALTER TABLE {TARGET_SCHEMA}.visit_detail ADD CONSTRAINT xpk_visit_detail PRIMARY KEY (visit_detail_id);	
CREATE INDEX idx_visit_detail_person_id  ON {TARGET_SCHEMA}.visit_detail (person_id, visit_detail_source_value);
CLUSTER {TARGET_SCHEMA}.visit_detail USING idx_visit_detail_person_id;
CREATE INDEX idx_visit_detail_concept_id ON {TARGET_SCHEMA}.visit_detail (visit_detail_concept_id ASC);
CREATE INDEX idx_visit_detail_occurrence_id ON {TARGET_SCHEMA}.visit_detail (visit_occurrence_id ASC);
