--------------------------------
-- LOCATION
--------------------------------
With cte as(
select distinct target_concept_id, target_concept_name
from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map
where source_vocabulary_id = 'UKB_COUNTRY_STCM'
)
insert into {TARGET_SCHEMA}.location
select 
	row_number() over (order by target_concept_name) as location_id, 
	NULL as address_1,
	NULL as address_2, 
	NULL as city, 
	NULL as state, 
	NULL as zip, 
	target_concept_name as county,
	NULL as location_source_value,
	target_concept_id as country_concept_id,
	target_concept_name as country_source_value,
	NULL as latitude,
	NULL as longitude
from cte;

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
), loc AS(
	select 	t1.source_code, 
			t2.location_id
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t1
	join {TARGET_SCHEMA}.location as t2 on t2.country_concept_id = t1.target_concept_id
	where t1.source_vocabulary_id = 'UKB_COUNTRY_STCM'
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
	t4.location_id as location_id,
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
left join ukb as t3 on CONCAT('1001-', t1.p21000_i0::integer) = t3.source_code
left join loc as t4 on t1.p54_i0::text = t4.source_code;

ALTER TABLE {TARGET_SCHEMA}.person ADD CONSTRAINT xpk_person PRIMARY KEY (person_id) USING INDEX TABLESPACE pg_default;
CREATE UNIQUE INDEX idx_person_id ON {TARGET_SCHEMA}.person (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.person USING xpk_person;
CREATE INDEX idx_gender ON {TARGET_SCHEMA}.person (gender_concept_id ASC) TABLESPACE pg_default;

--------------------------------
-- DEATH
--------------------------------
With ICD10_1 AS(
	select source_code
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map
	where source_vocabulary_id = 'ICD10' 
	group by source_concept_id, source_code
	having count(*)=1 
), STCM AS(
	select source_concept_id, source_code, target_concept_id
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map 
	where source_vocabulary_id = 'UKB_DEATH_CAUSE_STCM'	
), ICD10 AS(
	select t1.source_concept_id, t1.source_code, t1.target_concept_id
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t1
	join ICD10_1 as t2 on t1.source_code = t2.source_code
	where t1.source_vocabulary_id = 'ICD10'
), cte AS(
	select distinct 
		t1.eid,
		t1.date_of_death, 
		t2.cause_icd10
	from {SOURCE_SCHEMA}.death as t1
	left join {SOURCE_SCHEMA}.death_cause as t2 on t1.eid= t2.eid and t1.ins_index = t2.ins_index
), _death as(
	select ROW_NUMBER () OVER ( PARTITION BY eid order by eid, date_of_death, cause_icd10) as tmp_id,
	*
	from cte
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
		WHEN t1.cause_icd10 is not null THEN COALESCE(t3.target_concept_id, t4.target_concept_id, t5.target_concept_id, t6.target_concept_id, 0) 
	END as target_concept_id,
	COALESCE(t3.source_code, t5.source_code, t1.cause_icd10) as source_code,
	CASE 
		WHEN t1.cause_icd10 is null then null
		ELSE COALESCE(t3.source_concept_id, t5.source_concept_id, 0) 
	END as source_concept_id
from _death as t1
left join STCM as t3 on replace(t3.source_code, '.', '') = t1.cause_icd10
left join STCM as t4 on t4.source_code = left(t1.cause_icd10, 3)
left join ICD10 as t5 on replace(t5.source_code, '.', '') = t1.cause_icd10
left join ICD10 as t6 on t6.source_code = left(t1.cause_icd10, 3)
where t1.tmp_id = 1;

--------------------------------
-- OBSERVATION_PERIOD
--------------------------------
with cte as(
	select 
			distinct 
			t1.eid, 
			t1.p53_i0, 
			COALESCE(t2.date_of_death, to_date(RIGHT(current_database(), 8), 'YYYYMMDD')),
			32880		-- same as GOLD 
	from {SOURCE_SCHEMA}.baseline as t1
	left join {SOURCE_SCHEMA}.death as t2 on t1.eid = t2.eid
)
INSERT INTO {TARGET_SCHEMA}.observation_period
select 
	ROW_NUMBER () OVER ( ORDER BY eid) as observation_period_id, 
	* 
from cte;

ALTER TABLE {TARGET_SCHEMA}.observation_period ADD CONSTRAINT xpk_observation_period PRIMARY KEY (observation_period_id) USING INDEX TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_observation_period_id ON {TARGET_SCHEMA}.observation_period (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.observation_period USING idx_observation_period_id;

--------------------------------
-- Map p22189 "Townsend Deprivation Index" to Measurement
--------------------------------

-- SEQUENCE for ukb baseline Measurement
DROP SEQUENCE IF EXISTS {SOURCE_SCHEMA}.meas_seq;
CREATE SEQUENCE {SOURCE_SCHEMA}.meas_seq as bigint START WITH 1 INCREMENT BY 1 NO MAXVALUE CACHE 1;

insert into {TARGET_SCHEMA}.measurement
select 
	nextval('{SOURCE_SCHEMA}.meas_seq') as measurement_id,
	t1.eid,
	t2.target_concept_id as measurement_concept_id,
	t1.p53_i0 as measurement_date,			-- Initial assessment visit (2006-2010) at which participants were recruited and consent given
	t1.p53_i0 as measurement_datetime,
	NULL as measurement_time,
	32880 as measurement_type_concept_id,  -- Standard algorithm (Townsend deprivation index calculated immediately prior to participant joining UK Biobank.)
	NULL::int as operator_concept_id,
	t1.p22189 as value_as_number,
	NULL::int as value_as_concept_id,
	NULL::int as unit_concept_id,  
	NULL::int as range_low,
	NULL::int as range_high,
	NULL::int as provider_id,
	NULL::bigint as visit_occurrence_id,
	NULL::bigint as visit_detail_id,
	t2.source_code as measurement_source_value,
	t2.source_concept_id as measurement_source_concept_id,	
	NULL as unit_source_value, 
	NULL::int as unit_source_concept_id,
	NULL as value_source_value,
	NULL::bigint as measurement_event_id,
	NULL::int as meas_event_field_concept_id
from {SOURCE_SCHEMA}.baseline as t1
join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on '189' = t2.source_code 
join {TARGET_SCHEMA}.observation_period as t3 on t1.eid = t3.person_id
where t1.p22189 is not null
and t1.p53_i0 >= t3.observation_period_start_date and p53_i0 <= observation_period_end_date
and t2.source_vocabulary_id = 'UKB_MEASUREMENT_STCM'
and t2.target_domain_id = 'Measurement';
