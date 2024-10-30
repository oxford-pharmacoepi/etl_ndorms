--------------------------------
-- LOCATION
--------------------------------
INSERT INTO {TARGET_SCHEMA}.location
SELECT 
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
FROM {target_schema_to_link}.location;
--------------------------------
-- PERSON
--------------------------------
with cte1 as ( 
	select distinct(eid) as eid
	from {SOURCE_SCHEMA}.hesin as t1 
),
ukb AS(
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
SELECT 
	t1.eid AS person_id,
	t3.target_concept_id AS gender_concept_id,
	t2.p34 AS year_of_birth,
	t2.p52 AS month_of_birth,
	NULL::int AS day_of_birth,
	NULL::timestamp AS birth_datetime,
	CASE 
		WHEN t4.target_domain_id <> 'Race' THEN 0
		ELSE COALESCE(t4.target_concept_id, 0) 
	END	AS race_concept_id,
	0 AS ethnicity_concept_id,
	t5.location_id as location_id,
	NULL::bigint AS provider_id,
	NULL::int AS care_site_id,
	t1.eid::varchar AS person_source_value,
	CONCAT('9-', t2.p31) AS gender_source_value,
	t3.source_concept_id AS gender_source_concept_id,
	CASE
		WHEN t2.p21000_i0::integer is not null then CONCAT('1001-', t2.p21000_i0::integer)
	END 
	AS race_source_value,	
	t4.source_concept_id AS race_source_concept_id, 
	NULL AS ethnicity_source_value,
	NULL::int AS ethnicity_source_concept_id
FROM cte1 as t1
INNER JOIN {SOURCE_SCHEMA}.baseline AS t2 ON t1.eid = t2.eid 
JOIN ukb as t3 on CONCAT('9-', t2.p31) = t3.source_code and t3.target_domain_id = 'Gender'
LEFT JOIN ukb as t4 on CONCAT('1001-', t2.p21000_i0::integer) = t4.source_code
LEFT JOIN loc as t5 on t2.p54_i0::text = t5.source_code;

ALTER TABLE {TARGET_SCHEMA}.person ADD CONSTRAINT xpk_person PRIMARY KEY (person_id) USING INDEX TABLESPACE pg_default;
CREATE UNIQUE INDEX idx_person_id ON {TARGET_SCHEMA}.person (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.person USING xpk_person;
CREATE INDEX idx_gender ON {TARGET_SCHEMA}.person (gender_concept_id ASC) TABLESPACE pg_default;
--------------------------------
-- PROVIDER from hesin
--------------------------------
DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_pro;
CREATE SEQUENCE {TARGET_SCHEMA}.sequence_pro INCREMENT 1;
SELECT setval('{TARGET_SCHEMA}.sequence_pro', 
				(SELECT max_id from {TARGET_SCHEMA_TO_LINK}._max_ids WHERE lower(tbl_name) = 'provider'));

with cte1 AS (
	select DISTINCT CASE WHEN tretspef <> '&' THEN tretspef ELSE mainspef END as specialty
	from {SOURCE_SCHEMA}.hesin
	WHERE (tretspef <> '&' OR mainspef <> '&')
),
cte2 AS (
	SELECT 
	DISTINCT t2.target_concept_id AS specialty_concept_id, 
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
	NULL AS provider_source_value,
	specialty_source_value,
	NULL::int AS specialty_source_concept_id,
	NULL AS gender_source_value,
	NULL::int AS gender_source_concept_id
FROM cte2;

DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_pro;
--The following is used in the mapping
CREATE UNIQUE INDEX idx_provider_source ON {TARGET_SCHEMA}.provider (specialty_source_value ASC);
--------------------------------
-- DEATH
--------------------------------
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
	t1.person_id, 
	t1.death_date, 
	t1.death_datetime, 
	t1.death_type_concept_id,
	t1.cause_concept_id, 
	t1.cause_source_value, 
	t1.cause_source_concept_id
From {target_schema_to_link}.death as t1
inner join {TARGET_SCHEMA}.person as t2 on t1.person_id = t2.person_id;

ALTER TABLE {TARGET_SCHEMA}.death ADD CONSTRAINT xpk_death PRIMARY KEY (person_id) USING INDEX TABLESPACE pg_default;


--------------------------------
-- OBSERVATION_PERIOD --
--------------------------------
DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.observation_period_seq;

CREATE SEQUENCE {TARGET_SCHEMA}.observation_period_seq;

with cte as ( 
	SELECT 
		eid, 
		LEAST(MIN(admidate), MIN(epistart),MIN(disdate), MIN(epiend)) AS min_date, 
		GREATEST(MAX(disdate), MAX(epiend), MAX(admidate), MAX(epistart)) AS max_date
	FROM 
		{SOURCE_SCHEMA}.hesin
	GROUP BY 
		eid
	HAVING 
		(MIN(admidate) IS NOT NULL OR MIN(epistart) IS NOT NULL OR MIN(disdate) IS NOT NULL OR MIN(epiend) IS NOT NULL) AND 
		(MAX(disdate) IS NOT NULL OR MAX(epiend) IS NOT NULL OR MAX(admidate) IS NOT NULL OR MAX(epistart) IS NOT NULL)	
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
	eid,  
	min_date as observation_period_start_date,  
	max_date as observation_period_end_date,
	32880
from cte; 

DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.observation_period_seq;

ALTER TABLE {TARGET_SCHEMA}.observation_period ADD CONSTRAINT xpk_observation_period PRIMARY KEY (observation_period_id);
CREATE INDEX idx_observation_period_id ON {TARGET_SCHEMA}.observation_period (person_id ASC);
CLUSTER {TARGET_SCHEMA}.observation_period USING idx_observation_period_id;