--------------------------------
-- PERSON
--------------------------------
WITH cte1 as (
--	SELECT DISTINCT patid, ethnicityname
--	FROM {SOURCE_SCHEMA}.tumour
	select patid 
	from {SOURCE_SCHEMA}.tumour 
	group by patid 
	having count(*) = 1
),
cte2 as ( -- TO USE
	SELECT t1.patid, t1.ethnicityname
	FROM {SOURCE_SCHEMA}.tumour as t1
	inner join cte1 as t2 on t1.patid = t2.patid
),
cte3 as (
	SELECT distinct t1.patid, t1.ethnicityname 
	FROM {SOURCE_SCHEMA}.tumour as t1
	left join cte1 as t2 on t1.patid = t2.patid
	where t2.patid is null
	and t1.ethnicityname is not null 
--	and t1.ethnicity <> '0'
	and t1.ethnicityname not in ('NOT STATED', 'NOT KNOWN')
),
cte4 as (
	SELECT patid 
	from cte3 
	group by patid
	having count(*) = 1
),
cte5 as ( -- TO USE
	SELECT t1.*
	from cte3 as t1
	inner join cte4 as t2 on t1.patid = t2.patid
),
cte6 as (
	SELECT patid 
	from cte3 
	group by patid
	having count(*) > 1
),
cte7 as (
	SELECT distinct 
	t1.patid, t1.ethnicityname, length(t1.ethnicityname) as len
	FROM cte3 as t1
	inner join cte6 as t2 on t1.patid = t2.patid
	inner join cte3 as t3 on t1.patid = t3.patid 
	where t1.ethnicityname like '%' || t3.ethnicityname || '%'
),
cte8 as (
	select row_number() over (partition by patid order by patid, len DESC),
	patid, ethnicityname 
	from cte7
),
cte9 as (
	SELECT * from cte2
	UNION DISTINCT
	SELECT * from cte5
	UNION DISTINCT
	SELECT patid, ethnicityname from cte8 WHERE row_number = 1
),
cte10 as (
	select DISTINCT t1.patid, NULL as ethnicityname
	from {SOURCE_SCHEMA}.tumour as t1
	left join cte9 as t2 on t1.patid = t2.patid
	WHERE t2.patid is null
),
cte11 as (
	SELECT * FROM cte9
	UNION DISTINCT
	SELECT * FROM cte10
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
	t1.patid AS person_id,
	0 AS gender_concept_id,
	0 AS year_of_birth,
	NULL::int AS month_of_birth,
	NULL::int AS day_of_birth,
	NULL::timestamp AS birth_datetime,
	CASE WHEN t2.target_concept_id IS NOT NULL THEN t2.target_concept_id ELSE 0 END AS race_concept_id,
	0 AS ethnicity_concept_id,
	NULL::int AS location_id,
	NULL::int AS provider_id,
	NULL::int AS care_site_id,
	t1.patid::varchar AS person_source_value,
	NULL AS gender_source_value,
	NULL::int AS gender_source_concept_id,
	t2.source_code_description AS race_source_value,
	NULL::int AS race_source_concept_id, 
	NULL AS ethnicity_source_value,
	0 AS ethnicity_source_concept_id
FROM cte11 as t1
LEFT JOIN {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t1.ethnicityname = t2.source_code 
	and t2.source_vocabulary_id = 'NCRAS_ETHNIC_STCM';

ALTER TABLE {TARGET_SCHEMA}.person ADD CONSTRAINT xpk_person PRIMARY KEY (person_id) USING INDEX TABLESPACE pg_default;

CREATE UNIQUE INDEX idx_person_id ON {TARGET_SCHEMA}.person (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.person USING xpk_person;

--------------------------------
-- OBSERVATION_PERIOD --
--------------------------------
DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.observation_period_seq;

CREATE SEQUENCE {TARGET_SCHEMA}.observation_period_seq;

with cte2 as ( 
	select t1.patid as person_id, 
	LEAST(MIN(t1.diagnosisdatebest), MIN(t3.eventdate)) as min_date, 
	GREATEST(MAX(t1.diagnosisdatebest), MAX(t3.eventdate)) as max_date 
	from {SOURCE_SCHEMA}.tumour as t1 
	inner join {TARGET_SCHEMA}.person as t2 on t2.person_id = t1.patid 
	left join {SOURCE_SCHEMA}.treatment as t3 on t3.patid = t1.patid 
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
	cte2.person_id,  
	GREATEST(cte2.min_date, t3.start) as observation_period_start_date,  
	LEAST(cte2.max_date,t3.end) as observation_period_end_date,
	32880
from cte2, {LINKAGE_SCHEMA}.linkage_coverage as t3 
where t3.data_source = 'ncras_cr'; 

DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.observation_period_seq;

ALTER TABLE {TARGET_SCHEMA}.observation_period ADD CONSTRAINT xpk_observation_period PRIMARY KEY (observation_period_id) USING INDEX TABLESPACE pg_default;
CREATE INDEX idx_observation_period_id ON {TARGET_SCHEMA}.observation_period (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.observation_period USING idx_observation_period_id;