--------------------------------
-- PERSON
--------------------------------
INSERT INTO {TARGET_SCHEMA}.person (
  person_id					,
  gender_concept_id			,
  year_of_birth				,
  month_of_birth			,
  day_of_birth				,
  birth_datetime			,
  race_concept_id			,
  ethnicity_concept_id		,
  location_id				,
  provider_id				,
  care_site_id				,
  person_source_value		,
  gender_source_value		,
  gender_source_concept_id	,
  race_source_value			,
  race_source_concept_id	,
  ethnicity_source_value	,
  ethnicity_source_concept_id
)
SELECT 
	patid AS person_id,
	0 AS gender_concept_id,
	0 AS year_of_birth,
	NULL AS month_of_birth,
	NULL AS day_of_birth,
	NULL AS birth_datetime,
	CASE WHEN t2.target_concept_id IS NOT NULL THEN t2.target_concept_id ELSE 0 END AS race_concept_id,
	0 AS ethnicity_concept_id,
	NULL AS location_id,
	NULL AS provider_id,
	NULL AS care_site_id,
	patid::varchar AS person_source_value,
	NULL AS gender_source_value,
	NULL AS gender_source_concept_id,
	t2.source_code_description AS race_source_value,
	NULL AS race_source_concept_id, 
	NULL AS ethnicity_source_value,
	0 AS ethnicity_source_concept_id
FROM {SOURCE_SCHEMA}.hes_patient as t1
LEFT JOIN {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t1.gen_ethnicity = t2.source_code 
	and t2.source_vocabulary_id = 'CPRD_ETHNIC_STCM';

ALTER TABLE {TARGET_SCHEMA}.person ADD CONSTRAINT xpk_person PRIMARY KEY (person_id);

CREATE UNIQUE INDEX idx_person_id ON {TARGET_SCHEMA}.person (person_id ASC);
CLUSTER {TARGET_SCHEMA}.person USING xpk_person;

--------------------------------
-- PROVIDER from hes_episodes
--------------------------------
DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_pro;
CREATE SEQUENCE {TARGET_SCHEMA}.sequence_pro INCREMENT 1;
SELECT setval('{TARGET_SCHEMA}.sequence_pro', (SELECT next_id from {TARGET_SCHEMA}._next_ids WHERE lower(tbl_name) = 'provider'));

-- We have duplicated people with more than 1 speciality to save that information and use it in episodes
with cte1 AS (
	select distinct pconsult AS provider_source_value,
	CASE WHEN tretspef <> '&' THEN tretspef ELSE mainspef END as specialty
	from {SOURCE_SCHEMA}.hes_episodes
	WHERE pconsult <> '&'
	AND (tretspef <> '&' OR mainspef <> '&')
),
cte2 AS (
	SELECT DISTINCT t2.target_concept_id AS specialty_concept_id, 
	t1.provider_source_value,
	t2.source_code_description AS specialty_source_value
	FROM cte1 as t1
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_concept_map as t2 on t1.specialty = t2.source_code 
	and t2.source_vocabulary_id = 'HES_SPEC_STCM'
)
INSERT INTO {TARGET_SCHEMA}.PROVIDER (
	provider_id,
	provider_name,
	npi,
	dea,
	specialty_concept_id,
	care_site_id,
	year_of_birth,
	gender_concept_id,
	provider_source_value,
	specialty_source_value,
	specialty_source_concept_id,
	gender_source_value,
	gender_source_concept_id
)
SELECT 
	nextval('{TARGET_SCHEMA}.sequence_pro') AS provider_id,
	NULL AS provider_name,
	NULL AS npi,
	NULL AS dea,
	specialty_concept_id, 
	NULL::int AS care_site_id,
	NULL::int AS year_of_birth,
	NULL::int AS gender_concept_id,
	provider_source_value,
	specialty_source_value,
	NULL::int AS specialty_source_concept_id,
	NULL AS gender_source_value,
	NULL::int AS gender_source_concept_id
FROM cte2;

DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_pro;
--The following is used in the mapping
CREATE UNIQUE INDEX idx_provider_source ON {TARGET_SCHEMA}.provider (provider_source_value, specialty_source_value ASC);

--------------------------------
-- OBSERVATION_PERIOD --
--------------------------------
DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.observation_period_seq;

CREATE SEQUENCE {TARGET_SCHEMA}.observation_period_seq;

with cte as ( 
	select t1.patid, LEAST(MIN(t1.admidate), MIN(t2.epistart)) as min_date, 
	GREATEST(MAX(t1.discharged), MAX(t2.epiend)) as max_date --sometimes discharged is null
	from {SOURCE_SCHEMA}.hes_hospital as t1 
	inner join {SOURCE_SCHEMA}.hes_episodes as t2 on t2.patid = t1.patid 
	inner join {TARGET_SCHEMA}.person as t3 on t3.person_id = t1.patid 
	group by t1.patid 
) 
INSERT INTO {TARGET_SCHEMA}.OBSERVATION_PERIOD
 (
	observation_period_id,
	person_id,
	observation_period_start_date,
	observation_period_end_date,
	period_type_concept_id
 )
select
	nextval('{TARGET_SCHEMA}.observation_period_seq'),
	cte.patid,  
	GREATEST(cte.min_date, t3.start) as observation_period_start_date,  
	LEAST(cte.max_date,t3.end) as observation_period_end_date,
	32880
from cte, {LINKAGE_SCHEMA}.linkage_coverage as t3 
where t3.data_source = 'hes_apc'; 

DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.observation_period_seq;

ALTER TABLE {TARGET_SCHEMA}.observation_period ADD CONSTRAINT xpk_observation_period PRIMARY KEY (observation_period_id);
CREATE INDEX idx_observation_period_id ON {TARGET_SCHEMA}.observation_period (person_id ASC);
CLUSTER {TARGET_SCHEMA}.observation_period USING idx_observation_period_id;