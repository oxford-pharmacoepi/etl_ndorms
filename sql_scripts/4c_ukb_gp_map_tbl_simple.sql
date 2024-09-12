--------------------------------
-- LOCATION 
--------------------------------
With cte AS(
	select distinct target_concept_id, target_concept_name
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map
	where source_vocabulary_id = 'UKB_GP_COUNTRY_STCM'
)
INSERT INTO {TARGET_SCHEMA}.location (
	location_id, 
	address_1, 
	address_2, 
	city,
	state, 
	zip, 
	county, 
	location_source_value,
	country_concept_id,
	country_source_value,
	latitude,
	longitude
)
select 
	ROW_NUMBER () OVER ( ORDER BY target_concept_name) as location_id,
	null, 
	null, 
	null, 
	null, 
	null, 
	null, 
	null,
	target_concept_id as country_concept_id,
	target_concept_name as country_source_value,
	null, 
	null
from cte;

--------------------------------
-- CARE_SITE 
--------------------------------
With cte AS(
	select t1.location_id, t2.*
	from {TARGET_SCHEMA}.location as t1
	join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t1.country_concept_id= t2.target_concept_id
	where t2.source_vocabulary_id = 'UKB_GP_COUNTRY_STCM'
)
INSERT INTO {TARGET_SCHEMA}.care_site(
	care_site_id, 
	care_site_name, 
	place_of_service_concept_id,
	location_id, 
	care_site_source_value, 
	place_of_service_source_value
)
select 
	t1.code as care_site_id,
	t1.description as care_site_name,
	8977, 
	t2.location_id, 
	t1.code as care_site_source_value,
	null
from {SOURCE_SCHEMA}.lookup626 as t1
left join cte as t2 on t1.code::text = t2.source_code;

--------------------------------
-- PROVIDER
--------------------------------
INSERT INTO {TARGET_SCHEMA}.provider(
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
select 
	care_site_id as provider_id,
	null,
	null,
	null, 
	38004446,
	care_site_id, 
	null, 
	null, 
	CONCAT('GP-', care_site_name), 
	'General Practice',
	null,
	null,
	null 
from {TARGET_SCHEMA}.care_site;

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
	t1.p34,
	t1.p52,
	NULL::int,
	NULL::timestamp,
	CASE 
		WHEN t3.target_domain_id <> 'Race' THEN 0
		ELSE COALESCE(t3.target_concept_id, 0)
	END as race_concept_id,
	0,
	NULL::bigint,
	NULL::bigint,
	NULL::int, 
	t1.eid, 
	CONCAT('9-', t1.p31),
	t2.source_concept_id,
	CASE
		WHEN t1.p21000_i0::integer is not null then CONCAT('1001-', t1.p21000_i0::integer)
	END,
	t3.source_concept_id,
	null, 
	NULL::int
from {SOURCE_SCHEMA}.baseline as t1
join ukb as t2 on CONCAT('9-', t1.p31) = t2.source_code and t2.target_domain_id = 'Gender'
left join ukb as t3 on CONCAT('1001-', t1.p21000_i0::integer) = t3.source_code;

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
), STCM AS(
	select source_concept_id, source_code, target_concept_id, source_vocabulary_id
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map 
	where source_vocabulary_id = 'UKB_DEATH_CAUSE_STCM'	
), ICD10 AS(
	select t1.source_concept_id, t1.target_concept_id, t1.source_vocabulary_id
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t1
	join ICD10_1 as t2 on t1.source_concept_id = t2.source_concept_id
	left join STCM as t3 on t3.source_concept_id = t1.source_concept_id
	where t1.source_vocabulary_id = 'ICD10' and t3.source_concept_id is null

	union
	
	select source_concept_id, target_concept_id, source_vocabulary_id
	from STCM 
), death_cause_1 AS(
	select t1.eid, t1.ins_index, t1.cause_icd10, t2.concept_id, t2.concept_id as source_concept_id, t2.concept_code as source_code
	from {SOURCE_SCHEMA}.death_cause as t1
	join {VOCABULARY_SCHEMA}.concept as t2 on t1.cause_icd10 = t2.concept_code or t1.cause_icd10 = replace(t2.concept_code, '.', '')
	where t2.vocabulary_id = 'ICD10'
), death_cause_2 AS(
	select t1.eid, t1.ins_index, t1.cause_icd10, t3.concept_id, 0 as source_concept_id, t1.cause_icd10 as source_code
	from {SOURCE_SCHEMA}.death_cause as t1
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

ALTER TABLE {TARGET_SCHEMA}.death ADD CONSTRAINT xpk_death PRIMARY KEY (person_id) USING INDEX TABLESPACE pg_default;

--------------------------------
-- OBSERVATION_PERIOD
--------------------------------
With clinical AS(
	select eid, 
		min(event_dt) as min_event_dt,
		max(event_dt) as max_event_dt
	from {SOURCE_SCHEMA}.gp_clinical
	group by eid
), reg AS(
	select eid, 
		min(reg_date) as reg_date
	from {SOURCE_SCHEMA}.gp_registrations 
	group by eid
), prescript AS(
	select eid, 
		min(issue_date) as min_issue_date,
		max(issue_date) as max_issue_date
	from {SOURCE_SCHEMA}.gp_scripts
	group by eid
)
INSERT INTO {TARGET_SCHEMA}.observation_period(
	select 
		ROW_NUMBER () OVER ( ORDER BY t1.person_id) as observation_period_id,
		t1.person_id, 
		LEAST(t2.reg_date, t3.min_event_dt, t4.min_issue_date), 
		COALESCE(LEAST(t5.death_date, GREATEST(t3.max_event_dt, t4.max_issue_date)), to_date(RIGHT(current_database(), 8), 'YYYYMMDD')),
		32880		-- same as GOLD 
	from {TARGET_SCHEMA}.person as t1
	left join reg as t2 on t1.person_id = t2.eid
	left join clinical as t3 on t1.person_id = t3.eid
	left join prescript as t4 on t1.person_id = t4.eid
	left join {TARGET_SCHEMA}.death as t5 on t1.person_id = t5.person_id
);

ALTER TABLE {TARGET_SCHEMA}.death DROP CONSTRAINT xpk_death;  

ALTER TABLE {TARGET_SCHEMA}.observation_period ADD CONSTRAINT xpk_observation_period PRIMARY KEY (observation_period_id) USING INDEX TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_observation_period_id ON {TARGET_SCHEMA}.observation_period (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.observation_period USING idx_observation_period_id;