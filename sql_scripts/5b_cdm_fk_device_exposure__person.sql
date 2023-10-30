ALTER TABLE {TARGET_SCHEMA}.device_exposure ADD CONSTRAINT fpk_device_person FOREIGN KEY (person_id) REFERENCES {TARGET_SCHEMA}.person (person_id);
