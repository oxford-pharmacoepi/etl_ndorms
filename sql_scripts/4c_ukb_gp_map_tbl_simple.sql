--------------------------------
-- PERSON
--------------------------------
--INSERT INTO {TARGET_SCHEMA}.person
--select 
--	t1.eid,
--	t2.target_concept_id,
--	0,
--	NULL::int,
--	NULL::int,
--	NULL::timestamp,
--	0,
--	0,
--	NULL::bigint,
--	NULL::bigint,
--	NULL::int, 
--	t1.eid,
--	CONCAT('9-', t1.p31),
--	NULL::int,
--	NULL, 
--	NULL::int,
--	NULL, 
--	NULL::int
--from {SOURCE_SCHEMA}.baseline as t1
--left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on CONCAT('9-', t1.p31) = t2.source_code
--and t2.source_vocabulary_id = 'UK Biobank' and t2.source_code like '9-%';
--
--
--ALTER TABLE {TARGET_SCHEMA}.person ADD CONSTRAINT xpk_person PRIMARY KEY (person_id) USING INDEX TABLESPACE pg_default;
--CREATE UNIQUE INDEX idx_person_id ON {TARGET_SCHEMA}.person (person_id ASC) TABLESPACE pg_default;
--CLUSTER {TARGET_SCHEMA}.person USING xpk_person;
--CREATE INDEX idx_gender ON {TARGET_SCHEMA}.person (gender_concept_id ASC) TABLESPACE pg_default;
--
----------------------------------
---- DEATH
----------------------------------
--INSERT INTO {TARGET_SCHEMA}.death
--select distinct
--	eid,
--	date_of_death, 
--	date_of_death, 
--	32879, --same as cdm_ukb_202003
--	NULL::int, 
--	NULL, 
--	NULL::int
--from {SOURCE_SCHEMA}.death;
--
--ALTER TABLE {TARGET_SCHEMA}.death ADD CONSTRAINT xpk_death PRIMARY KEY (person_id) USING INDEX TABLESPACE pg_default;
--
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
		LEAST(t2.reg_date, t3.min_event_dt, t4.min_issue_date) as observation_period_start_date, 
		COALESCE(LEAST(t5.death_date, GREATEST(t3.max_event_dt, t4.max_issue_date)), to_date(RIGHT(current_database(), 6), 'YYYYMM' || '01')) as observation_period_end_date,
		32880		-- same as GOLD 
	from {TARGET_SCHEMA_TO_LINK}.person as t1
	left join reg as t2 on t1.person_id = t2.eid
	left join clinical as t3 on t1.person_id = t3.eid
	left join prescript as t4 on t1.person_id = t4.eid
	left join {TARGET_SCHEMA_TO_LINK}.death as t5 on t1.person_id = t5.person_id
	WHERE t2.eid is not null or t3.eid is not null or t4.eid is not null
);

--ALTER TABLE {TARGET_SCHEMA}.death DROP CONSTRAINT xpk_death;  

ALTER TABLE {TARGET_SCHEMA}.observation_period ADD CONSTRAINT xpk_observation_period PRIMARY KEY (observation_period_id) USING INDEX TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_observation_period_id ON {TARGET_SCHEMA}.observation_period (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.observation_period USING idx_observation_period_id;