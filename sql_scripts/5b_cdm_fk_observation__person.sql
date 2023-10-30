ALTER TABLE {TARGET_SCHEMA}.observation ADD CONSTRAINT fpk_observation_person FOREIGN KEY (person_id) REFERENCES {TARGET_SCHEMA}.person (person_id);
