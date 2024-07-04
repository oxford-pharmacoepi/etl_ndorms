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
With ukb AS(
	select 
		t1.concept_id as source_concept_id, 
		t1.concept_code as source_code, 
		COALESCE(t2.target_concept_id, 0) as target_concept_id, 
		t2.target_domain_id
	from {VOCABULARY_SCHEMA}.concept as t1
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t1.concept_id = t2.source_concept_id and t2.source_vocabulary_id = 'UK Biobank'
	where t1.vocabulary_id = 'UK Biobank' and (t1.concept_code like '1001-%' or t1.concept_code like '9-%')
)
select 
	t1.eid,
	t2.target_concept_id,
	t1."34",
	t1."52",
	NULL::int,
	NULL::timestamp,
	COALESCE(t3.target_concept_id, 0),
	0,
	NULL::bigint,
	NULL::bigint,
	NULL::int, 
	t1.eid, 
	CONCAT('9-', t1."31"),
	t2.source_concept_id,
	CASE
		WHEN t1."21000" is not null then CONCAT('1001-', t1."21000")
	END,
	t3.source_concept_id,
	null, 
	NULL::int
from {SOURCE_SCHEMA}.baseline as t1
join ukb as t2 on CONCAT('9-', t1."31") = t2.source_code and t2.target_domain_id = 'Gender'
left join ukb as t3 on CONCAT('1001-', t1."21000") = t3.source_code and t3.target_domain_id = 'Race';

ALTER TABLE {TARGET_SCHEMA}.person ADD CONSTRAINT xpk_person PRIMARY KEY (person_id) USING INDEX TABLESPACE pg_default;
CREATE UNIQUE INDEX idx_person_id ON {TARGET_SCHEMA}.person (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.person USING xpk_person;
CREATE INDEX idx_gender ON {TARGET_SCHEMA}.person (gender_concept_id ASC) TABLESPACE pg_default;

--------------------------------
-- DEATH
--------------------------------
INSERT INTO {TARGET_SCHEMA}.death(person_id, death_date, death_datetime, death_type_concept_id,
									cause_concept_id, cause_source_value, cause_source_concept_id)
With ICD10_1 AS(
	select source_concept_id, source_code
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map
	where source_vocabulary_id = 'ICD10' 
	group by source_concept_id, source_code
	having count(*)=1 
), ICD10 AS(
	select t1.source_concept_id, t1.target_concept_id
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t1
	join ICD10_1 as t2 on t1.source_concept_id = t2.source_concept_id
	where t1.source_vocabulary_id = 'ICD10' 
), death_cause AS(
	select t1.eid, t1.ins_index, t1.cause_icd10, t2.concept_id
	from {SOURCE_SCHEMA}.death_cause as t1
	join {VOCABULARY_SCHEMA}.concept as t2 on t1.cause_icd10 = t2.concept_code or t1.cause_icd10 = replace(t2.concept_code, '.', '') 
	where t2.vocabulary_id = 'ICD10'
), dead_patient AS(
	select distinct t1.eid, t1.date_of_death, t2.cause_icd10, t2.concept_id
	from {SOURCE_SCHEMA}.death as t1
	left join death_cause as t2 on t1.eid = t2.eid and t1.ins_index = t2.ins_index
)
select 
t1.eid as person_id,
t1.date_of_death as death_date, 
t1.date_of_death as death_datetime, 
32879 as death_type_concept_id, --same as cdm_ukb_202003
CASE 
	WHEN t1.cause_icd10 is not null THEN COALESCE(t2.target_concept_id, 0) 
END as cause_concept_id, 
t1.cause_icd10 as cause_source_value, 
t1.concept_id as cause_source_concept_id
from dead_patient as t1
left join ICD10 as t2 on t1.concept_id = t2.source_concept_id;