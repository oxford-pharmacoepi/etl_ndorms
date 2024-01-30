--------------------------------
-- LOCATION 
--------------------------------
WITH cte1 as (
	SELECT DISTINCT r.regionid, r."description"
	FROM {SOURCE_SCHEMA}.practice as p
	INNER JOIN {SOURCE_SCHEMA}.region as r on p.region = r.regionid	
)
INSERT INTO {TARGET_SCHEMA}.location (location_id, address_1, address_2, city,
										state, zip, county, location_source_value)
SELECT cte1.regionid,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		cte1."description"
FROM cte1;

--------------------------------
-- CARE_SITE 
--------------------------------
INSERT INTO {TARGET_SCHEMA}.care_site(care_site_id, care_site_name, place_of_service_concept_id,
										location_id, care_site_source_value, place_of_service_source_value)
SELECT pracid,
		NULL,
		8977,
		region,
		pracid::varchar,
		NULL
FROM {SOURCE_SCHEMA}.practice;

--------------------------------
-- PROVIDER
--------------------------------
WITH cte2 as (
	SELECT s.staffid,
		s.pracid,
		j."description"
	FROM {SOURCE_SCHEMA}.staff as s
	LEFT JOIN {SOURCE_SCHEMA}.jobcat as j on s.jobcatid = j.jobcatid
)
INSERT INTO {TARGET_SCHEMA}.provider(provider_id, provider_name, npi, dea, specialty_concept_id, care_site_id,
									  year_of_birth, gender_concept_id, provider_source_value, specialty_source_value,
									  specialty_source_concept_id, gender_source_value, gender_source_concept_id)
SELECT cte2.staffid, 
		NULL,
		NULL,
		NULL,
		stcm.target_concept_id,
		cte2.pracid,
		NULL::int,
		0,
		cte2.staffid::varchar,
		cte2."description",
		0,
		NULL,
		0
FROM cte2
LEFT JOIN {TARGET_SCHEMA}.SOURCE_TO_CONCEPT_MAP as stcm on stcm.source_code = cte2."description" and lower(stcm.source_vocabulary_id) = 'aurum_jobcat';

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
SELECT patid,
	case when gender = 2 then 8532
		when gender = 1 then 8507
	end,
	yob,
	mob,
	NULL::int,
	NULL::timestamp,
	0,
	0,
	NULL::bigint,
	usualgpstaffid,
	pracid,
	patid::varchar,
	case when gender = 2 then 'F'
		when gender = 1 then 'M'
	end,
	0,
	NULL,
	0,
	NULL,
	0
FROM {SOURCE_SCHEMA}.patient;

ALTER TABLE {TARGET_SCHEMA}.person ADD CONSTRAINT xpk_person PRIMARY KEY (person_id) USING INDEX TABLESPACE pg_default;
CREATE UNIQUE INDEX idx_person_id ON {TARGET_SCHEMA}.person (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.person USING xpk_person;
CREATE INDEX idx_gender ON {TARGET_SCHEMA}.person (gender_concept_id ASC) TABLESPACE pg_default;

--------------------------------
-- DEATH
--------------------------------
INSERT INTO {TARGET_SCHEMA}.death(person_id, death_date, death_datetime, death_type_concept_id,
									cause_concept_id, cause_source_value, cause_source_concept_id)
SELECT patid,
	cprd_ddate,
	NULL::timestamp,
	32815,
	0,
	NULL,
	0
FROM {SOURCE_SCHEMA}.patient
where cprd_ddate is not NULL;

--------------------------------
-- OBSERVATION_PERIOD
--------------------------------
WITH cte3 as (
	SELECT
		p.patid,
		p.regstartdate,
		least(p.cprd_ddate, p.regenddate, pr.lcd),
		32882
	FROM {SOURCE_SCHEMA}.patient p
	INNER JOIN {SOURCE_SCHEMA}.practice pr on p.pracid = pr.pracid
)
INSERT INTO {TARGET_SCHEMA}.observation_period(observation_period_id, person_id, observation_period_start_date,
												observation_period_end_date, period_type_concept_id)
SELECT 
	row_number() over (order by patid),
	cte3.*
FROM cte3;

ALTER TABLE {TARGET_SCHEMA}.observation_period ADD CONSTRAINT xpk_observation_period PRIMARY KEY (observation_period_id) USING INDEX TABLESPACE pg_default;

CREATE INDEX idx_observation_period_id ON {TARGET_SCHEMA}.observation_period (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.observation_period USING idx_observation_period_id;
