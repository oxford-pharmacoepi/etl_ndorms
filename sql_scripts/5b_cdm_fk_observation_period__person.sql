ALTER TABLE {TARGET_SCHEMA}.observation_period ADD CONSTRAINT fpk_observation_period_person FOREIGN KEY (person_id) REFERENCES {TARGET_SCHEMA}.person (person_id);
