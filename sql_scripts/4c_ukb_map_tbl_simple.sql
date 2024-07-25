--------------------------------
-- PROVIDER
--------------------------------
With ukb_spec AS(
	select CONCAT('269-', t1.code) as specialty_source_value, t1.description, t2.*
	from {SOURCE_SCHEMA}.lookup269 as t1
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_code = CONCAT('269-', t1.code)
	and (t2.source_vocabulary_id = 'UKB_SPEC_STCM' or t2.source_vocabulary_id = 'UK Biobank')
	and t2.target_domain_id = 'Provider'
	where t1.code <> 9999 -- "Not known"
	
	union
	
	select CONCAT('270-', t1.code) as specialty_source_value, t1.description, t2.*
	from {SOURCE_SCHEMA}.lookup270 as t1
	left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_code = CONCAT('270-', t1.code)
	and (t2.source_vocabulary_id = 'UKB_SPEC_STCM' or t2.source_vocabulary_id = 'UK Biobank')
	and t2.target_domain_id = 'Provider'
	where t1.code <> 9999 -- "Not known"
)
INSERT INTO {TARGET_SCHEMA}.provider(
	provider_id, 
	provider_name, 
	npi, dea, 
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
select
	ROW_NUMBER () OVER ( ORDER BY specialty_source_value) as provider_id,
	null,
	null,
	null, 
	target_concept_id,
	null, 
	null, 
	null, 
	description, 
	specialty_source_value,
	CASE
		when source_concept_id = 0 THEN null
		else source_concept_id
	END,
	null,
	null 
from ukb_spec;

INSERT INTO {TARGET_SCHEMA}.provider(
	provider_id, 
	provider_name, 
	npi, dea, 
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
select 
(max(provider_id) + 1), 
null,
null,
null, 
38004446,
null, 
null, 
null, 
'General Practice', 
'GP',
null,
null,
null 
from {TARGET_SCHEMA}.provider;


--------------------------------
-- PERSON
--------------------------------
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
left join ukb as t3 on CONCAT('1001-', t1."21000") = t3.source_code;

ALTER TABLE {TARGET_SCHEMA}.person ADD CONSTRAINT xpk_person PRIMARY KEY (person_id) USING INDEX TABLESPACE pg_default;
CREATE UNIQUE INDEX idx_person_id ON {TARGET_SCHEMA}.person (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.person USING xpk_person;
CREATE INDEX idx_gender ON {TARGET_SCHEMA}.person (gender_concept_id ASC) TABLESPACE pg_default;

--------------------------------
-- DEATH
--------------------------------
With ICD10_1 AS(
	select source_concept_id, source_code
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map
	where source_vocabulary_id = 'ICD10' 
	group by source_concept_id, source_code
	having count(*)=1 
), ICD10 AS(
	select t1.source_concept_id, t1.target_concept_id, t1.source_vocabulary_id
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t1
	join ICD10_1 as t2 on t1.source_concept_id = t2.source_concept_id
	where t1.source_vocabulary_id = 'ICD10' 
	
	union
	
	select source_concept_id, target_concept_id, source_vocabulary_id
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map 
	where source_vocabulary_id = 'UKB_DEATH_CAUSE_STCM'	
), death_cause_1 AS(
	select t1.eid, t1.ins_index, t1.cause_icd10, t2.concept_id, t2.concept_id as source_concept_id, t2.concept_code as source_code
	from source.death_cause as t1
	join {VOCABULARY_SCHEMA}.concept as t2 on t1.cause_icd10 = t2.concept_code or t1.cause_icd10 = replace(t2.concept_code, '.', '')
	where t2.vocabulary_id = 'ICD10'
), death_cause_2 AS(
	select t1.eid, t1.ins_index, t1.cause_icd10, t3.concept_id, 0 as source_concept_id, t1.cause_icd10 as source_code
	from source.death_cause as t1
	left join death_cause_1 as t2 on t1.eid = t2.eid and t1.ins_index = t2.ins_index
	join {VOCABULARY_SCHEMA}.concept as t3 on left(t1.cause_icd10, 3) = t3.concept_code 
	where t2.eid is null and t3.vocabulary_id = 'ICD10'
), death_cause AS(
	select * from death_cause_1
	union 
	select * from death_cause_2
), dead_patient AS(
	select distinct t1.eid, t1.date_of_death, t2.cause_icd10, t2.source_code, t2.concept_id, t2.source_concept_id
	from {SOURCE_SCHEMA}.death as t1
	left join death_cause as t2 on t1.eid = t2.eid and t1.ins_index = t2.ins_index
)
INSERT INTO {TARGET_SCHEMA}.death(
	person_id, 
	death_date, 
	death_datetime, 
	death_type_concept_id,
	cause_concept_id, 
	cause_source_value, 
	cause_source_concept_id
)
select 
t1.eid,
t1.date_of_death, 
t1.date_of_death, 
32879, --same as cdm_ukb_202003
CASE 
	WHEN t1.cause_icd10 is not null THEN COALESCE(t2.target_concept_id, 0) 
END, 
t1.source_code, 
t1.source_concept_id
from dead_patient as t1
left join ICD10 as t2 on t1.concept_id = t2.source_concept_id
and (t2.source_vocabulary_id = 'UKB_DEATH_CAUSE_STCM' or t2.source_vocabulary_id = 'ICD10');