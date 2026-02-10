--------------------------------
-- OBSERVATION_PERIOD
--------------------------------
With cancer AS(
	select 	eid, 
			min(p40005) as min_p40005,
			max(p40005) as max_p40005
	from {SOURCE_SCHEMA}.cancer_longitude
	group by eid
)
INSERT INTO {TARGET_SCHEMA}.observation_period(
	select 
		ROW_NUMBER () OVER ( ORDER BY t1.person_id) as observation_period_id,
		t1.person_id, 
		min_p40005, 
		max_p40005,
		32879			--Registry		
	from {TARGET_SCHEMA_TO_LINK}.person as t1
	join cancer as t2 on t1.person_id = t2.eid
);

ALTER TABLE {TARGET_SCHEMA}.observation_period ADD CONSTRAINT xpk_observation_period PRIMARY KEY (observation_period_id) USING INDEX TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_observation_period_id ON {TARGET_SCHEMA}.observation_period (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.observation_period USING idx_observation_period_id;