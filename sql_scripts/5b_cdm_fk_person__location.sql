ALTER TABLE person ADD CONSTRAINT fpk_person_location FOREIGN KEY (location_id)  REFERENCES location (location_id);
