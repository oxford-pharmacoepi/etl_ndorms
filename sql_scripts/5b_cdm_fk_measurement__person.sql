ALTER TABLE {TARGET_SCHEMA}.measurement ADD CONSTRAINT fpk_measurement_person FOREIGN KEY (person_id) REFERENCES {TARGET_SCHEMA}.person (person_id);
