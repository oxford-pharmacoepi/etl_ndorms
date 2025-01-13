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
FROM public_ukb.location;
--------------------------------
-- PERSON
--------------------------------
INSERT INTO {TARGET_SCHEMA}.person
select 
	t1.eid,
	t2.target_concept_id,
	0,
	NULL::int,
	NULL::int,
	NULL::timestamp,
	0,
	0,
	NULL::bigint,
	NULL::bigint,
	NULL::int, 
	t1.eid,
	CONCAT('9-', t1.p31),
	NULL::int,
	NULL, 
	NULL::int,
	NULL, 
	NULL::int
from {SOURCE_SCHEMA}.baseline as t1
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on CONCAT('9-', t1.p31) = t2.source_code
and t2.source_vocabulary_id = 'UK Biobank' and t2.source_code like '9-%'
inner join {SOURCE_SCHEMA}.hesin as t3 on t1.eid = t3.eid;

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
CREATE UNIQUE INDEX idx_provider_source ON {TARGET_SCHEMA}.provider (specialty_source_value ASC) TABLESPACE pg_default;
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
From public_ukb.death as t1
inner join {TARGET_SCHEMA}.person as t2 on t1.person_id = t2.person_id;

ALTER TABLE {TARGET_SCHEMA}.death ADD CONSTRAINT xpk_death PRIMARY KEY (person_id) USING INDEX TABLESPACE pg_default ;
CREATE INDEX idx_death_person_id_1 ON {TARGET_SCHEMA}.death (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.death USING idx_death_person_id_1;

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
	t1.eid,  
	t1.min_date as observation_period_start_date,  
	LEAST(t1.max_date,t2.death_date)  as observation_period_end_date,
	32880
from cte as t1
left join public_ukb.death as t2
on t1.eid = t2.person_id; 

DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.observation_period_seq;

ALTER TABLE {TARGET_SCHEMA}.observation_period ADD CONSTRAINT xpk_observation_period PRIMARY KEY (observation_period_id);
CREATE INDEX idx_observation_period_id ON {TARGET_SCHEMA}.observation_period (person_id ASC);
CLUSTER {TARGET_SCHEMA}.observation_period USING idx_observation_period_id;