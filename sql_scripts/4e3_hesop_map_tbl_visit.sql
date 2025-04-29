--------------------------------
-- VISIT_OCCURRENCE FROM hesop_appointment, hesop_clinical
--------------------------------
DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_vo;
CREATE SEQUENCE {TARGET_SCHEMA}.sequence_vo INCREMENT 1;
SELECT setval('{TARGET_SCHEMA}.sequence_vo', 
			(SELECT next_id from {TARGET_SCHEMA}._next_ids WHERE lower(tbl_name) = 'visit_occurrence'));

with cte1 AS (
	SELECT person_id, observation_period_start_date, observation_period_end_date
	FROM {TARGET_SCHEMA}.observation_period
),
cte2 AS (
	select t1.person_id, t2.attendkey,
	CASE WHEN t2.tretspef <> '&' THEN t2.tretspef ELSE CASE WHEN t2.mainspef <> '&' THEN t2.mainspef ELSE Null END END as specialty
	FROM cte1 as t1
	INNER JOIN {SOURCE_SCHEMA}.hesop_clinical AS t2 on t1.person_id = t2.patid
	UNION DISTINCT
	select t1.person_id, t2.attendkey,
	CASE WHEN t2.tretspef <> '&' THEN t2.tretspef ELSE CASE WHEN t2.mainspef <> '&' THEN t2.mainspef ELSE Null END END as specialty
	FROM cte1 as t1
	INNER JOIN {SOURCE_SCHEMA}.hesop_operation AS t2 on t1.person_id = t2.patid
),	
cte3 AS (	
	select t1.person_id, t1.attendkey, t3.provider_id
	FROM cte2 as t1
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_concept_map as t2 on t1.specialty = t2.source_code 
	and t2.source_vocabulary_id = 'HES_SPEC_STCM'
	LEFT JOIN {TARGET_SCHEMA}.provider as t3 on t3.specialty_source_value = t2.source_code_description
),
cte4 AS (
	SELECT
	NEXTVAL('{TARGET_SCHEMA}.sequence_vo') AS visit_occurrence_id,
	t1.patid AS person_id,
	9202 AS visit_concept_id,
	t1.apptdate AS visit_start_date, 
	t1.apptdate AS visit_start_datetime,
	t1.apptdate AS visit_end_date,
	t1.apptdate AS visit_end_datetime,
	32818 AS visit_type_concept_id,
	t3.provider_id,
	NULL::int AS care_site_id,
	t1.attendkey AS visit_source_value,
	NULL::int AS visit_source_concept_id,
	NULL::varchar AS admitting_source_value,
	NULL::int AS admitting_source_concept_id,
	NULL::varchar AS discharge_to_source_value,
	NULL::int AS discharge_to_concept_id
	FROM {SOURCE_SCHEMA}.hesop_appointment AS t1
	INNER JOIN cte1 as t2 ON t1.patid_id = t2.person_id
	INNER JOIN cte3 as t3 ON t1.patid = t3.person_id AND t1.attendkey = t3.attendkey
	WHERE t1.attended in (5, 6)     -- Seen
	AND t1.apptdate >= t2.observation_period_start_date
	AND t1.apptdate <= t2.observation_period_end_date
	ORDER BY t1.patid, t1.apptdate, t1.attendkey
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
	t1.*,
	t2.preceding_visit_occurrence_id
	FROM cte4 AS t1
	LEFT JOIN cte5 AS t2 ON t1.visit_occurrence_id = t2.visit_occurrence_id;

DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_vo;

ALTER TABLE {TARGET_SCHEMA}.visit_occurrence ADD CONSTRAINT xpk_visit_occurrence PRIMARY KEY (visit_occurrence_id);
CREATE INDEX idx_visit_occurrence_person_id ON {TARGET_SCHEMA}.visit_occurrence (person_id, visit_start_date);
CLUSTER {TARGET_SCHEMA}.visit_occurrence USING idx_visit_occurrence_person_id;
CREATE INDEX idx_visit_concept_id ON {TARGET_SCHEMA}.visit_occurrence (visit_concept_id ASC);
CREATE INDEX idx_visit_source_value ON {TARGET_SCHEMA}.visit_occurrence (visit_source_value ASC);

--------------------------------
-- VISIT_DETAIL FROM hesop_appointment
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
	NEXTVAL('{TARGET_SCHEMA}.sequence_vd') AS visit_detail_id,
	t1.patid AS person_id,
	9202 AS visit_detail_concept_id,
	t1.apptdate AS visit_detail_start_date,
	t1.apptdate AS visit_detail_start_datetime,
	t1.apptdate AS visit_detail_end_date,
	t1.apptdate AS visit_detail_end_datetime,
	32818 AS visit_detail_type_concept_id,
	NULL::int AS care_site_id,
	t1.attendkey AS visit_detail_source_value,
	NULL::int AS visit_detail_source_concept_id,
	NULL::int AS admitting_source_value,	
	NULL::int AS admitting_source_concept_id,				
	NULL::varchar AS discharge_to_source_value,		
	NULL::int AS discharge_to_concept_id,			
	NULL::int AS preceding_visit_detail_id, 					
	NULL::int AS visit_detail_parent_id
	FROM {SOURCE_SCHEMA}.hesop_appointment AS t1
	INNER JOIN cte1 as t2 ON t1.patid = t2.person_id
	WHERE t1.attended = 5     -- 5 = (Seen, having attended on time or, if late, before the relevant care professional was ready to see the patient)
	AND t1.apptdate >= t2.observation_period_start_date
	AND t1.apptdate <= t2.observation_period_end_date
	ORDER BY t1.patid, t1.apptdate, t1.attendkey
),
cte3 AS (
	SELECT 
	t1.*,
	t2.visit_occurrence_id, t2.provider_id
	FROM cte2 as t1
	INNER JOIN {TARGET_SCHEMA}.visit_occurrence AS t2 ON t1.person_id = t2.person_id and t1.visit_detail_source_value = t2.visit_source_value::bigint
),
cte4 AS (
	SELECT t1.person_id, t1.visit_detail_id, MAX(t2.visit_detail_id) AS preceding_visit_detail_id 
	FROM cte3 AS t1
	INNER JOIN cte3 AS t2 ON t1.person_id = t2.person_id
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
FROM cte3 as t1
LEFT JOIN cte4 AS t2 ON t1.visit_detail_id = t2.visit_detail_id;

DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_vd;

ALTER TABLE {TARGET_SCHEMA}.visit_detail ADD CONSTRAINT xpk_visit_detail PRIMARY KEY (visit_detail_id);	
CREATE INDEX idx_visit_detail_person_id  ON {TARGET_SCHEMA}.visit_detail (person_id, visit_detail_source_value);
CLUSTER {TARGET_SCHEMA}.visit_detail USING idx_visit_detail_person_id;
CREATE INDEX idx_visit_detail_concept_id ON {TARGET_SCHEMA}.visit_detail (visit_detail_concept_id ASC);
CREATE INDEX idx_visit_detail_occurrence_id ON {TARGET_SCHEMA}.visit_detail (visit_occurrence_id ASC);