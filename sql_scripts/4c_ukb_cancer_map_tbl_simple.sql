--------------------------------
-- PERSON
--------------------------------
INSERT INTO {TARGET_SCHEMA}.person
select 
	eid,
	0,
	0,
	NULL::int,
	NULL::int,
	NULL::timestamp,
	0,
	0,
	NULL::bigint,
	NULL::bigint,
	NULL::int, 
	eid,
	NULL,
	NULL::int,
	NULL, 
	NULL::int,
	NULL, 
	NULL::int
from {SOURCE_SCHEMA}.baseline;

ALTER TABLE {TARGET_SCHEMA}.person ADD CONSTRAINT xpk_person PRIMARY KEY (person_id) USING INDEX TABLESPACE pg_default;
CREATE UNIQUE INDEX idx_person_id ON {TARGET_SCHEMA}.person (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.person USING xpk_person;
CREATE INDEX idx_gender ON {TARGET_SCHEMA}.person (gender_concept_id ASC) TABLESPACE pg_default;

--------------------------------
-- DEATH
--------------------------------
INSERT INTO {TARGET_SCHEMA}.death
select distinct
	eid,
	date_of_death, 
	date_of_death, 
	32879, --same as cdm_ukb_202003
	NULL::int, 
	NULL, 
	NULL::int
from {SOURCE_SCHEMA}.death;

ALTER TABLE {TARGET_SCHEMA}.death ADD CONSTRAINT xpk_death PRIMARY KEY (person_id) USING INDEX TABLESPACE pg_default;

--------------------------------
-- OBSERVATION_PERIOD
--------------------------------
With cancer AS(
	select 	eid, 
			min(p40005) as min_p40005,
			max(p40005) as max_p40005
	from {SOURCE_SCHEMA}.cancer2
	group by eid
), cte1 as(
	select distinct
		t2.eid as person_id,
		t2.min_p40005,
		COALESCE(LEAST(t3.death_date, max_p40005), to_date(RIGHT(current_database(), 8), 'YYYYMMDD')) as op_end_date
	from {TARGET_SCHEMA}.person as t1
	join cancer as t2 on t1.person_id = t2.eid
	left join {TARGET_SCHEMA}.death as t3 on t1.person_id = t3.person_id
)
INSERT INTO {TARGET_SCHEMA}.observation_period
select 
	ROW_NUMBER () OVER ( ORDER BY person_id) as observation_period_id,
	person_id, 
	min_p40005, 
	op_end_date,		
	32879				--Registry		
from cte1;

ALTER TABLE {TARGET_SCHEMA}.death DROP CONSTRAINT xpk_death;  

ALTER TABLE {TARGET_SCHEMA}.observation_period ADD CONSTRAINT xpk_observation_period PRIMARY KEY (observation_period_id) USING INDEX TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_observation_period_id ON {TARGET_SCHEMA}.observation_period (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.observation_period USING idx_observation_period_id;