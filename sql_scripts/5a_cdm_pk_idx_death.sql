ALTER TABLE {TARGET_SCHEMA}.death ADD CONSTRAINT xpk_death PRIMARY KEY (person_id) USING INDEX TABLESPACE pg_default;

CREATE INDEX idx_death_person_id_1 ON {TARGET_SCHEMA}.death (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.death USING idx_death_person_id_1;
