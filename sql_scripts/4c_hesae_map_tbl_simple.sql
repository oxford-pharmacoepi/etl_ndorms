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