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
FROM {SOURCE_SCHEMA}.hesae_patient as t1
LEFT JOIN {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t1.gen_ethnicity = t2.source_code 
	and t2.source_vocabulary_id = 'CPRD_ETHNIC_STCM';

ALTER TABLE {TARGET_SCHEMA}.person ADD CONSTRAINT xpk_person PRIMARY KEY (person_id);

CREATE UNIQUE INDEX idx_person_id ON {TARGET_SCHEMA}.person (person_id ASC);
CLUSTER {TARGET_SCHEMA}.person USING xpk_person;

--------------------------------
-- OBSERVATION_PERIOD --
--------------------------------
DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.observation_period_seq;

CREATE SEQUENCE {TARGET_SCHEMA}.observation_period_seq;

with cte as ( 
	select t1.patid, MIN(t1.arrivaldate) as min_date, MAX(t1.arrivaldate) as max_date 
	from {SOURCE_SCHEMA}.hesae_attendance as t1 
	inner join {TARGET_SCHEMA}.person as t2 on t2.person_id = t1.patid 
	group by t1.patid 
	)
INSERT INTO {TARGET_SCHEMA}.OBSERVATION_PERIOD (
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
from cte, {SOURCE_SCHEMA}.linkage_coverage as t3 
where t3.data_source = 'hes_ae'; 

DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.observation_period_seq;

ALTER TABLE {TARGET_SCHEMA}.observation_period ADD CONSTRAINT xpk_observation_period PRIMARY KEY (observation_period_id);
CREATE INDEX idx_observation_period_id ON {TARGET_SCHEMA}.observation_period (person_id ASC);
CLUSTER {TARGET_SCHEMA}.observation_period USING idx_observation_period_id;																														 