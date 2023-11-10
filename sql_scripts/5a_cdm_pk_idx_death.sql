ALTER TABLE {TARGET_SCHEMA}.death ADD CONSTRAINT xpk_death PRIMARY KEY (person_id);

CREATE INDEX idx_death_person_id_1  ON {TARGET_SCHEMA}.death  (person_id ASC);
CLUSTER {TARGET_SCHEMA}.death  USING idx_death_person_id_1;
