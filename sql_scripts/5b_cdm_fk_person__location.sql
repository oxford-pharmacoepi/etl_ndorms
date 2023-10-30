ALTER TABLE {TARGET_SCHEMA}.person ADD CONSTRAINT fpk_person_location FOREIGN KEY (location_id) REFERENCES {TARGET_SCHEMA}.location (location_id);
