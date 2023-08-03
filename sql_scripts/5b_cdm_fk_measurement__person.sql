ALTER TABLE measurement ADD CONSTRAINT fpk_measurement_person FOREIGN KEY (person_id)  REFERENCES person (person_id);
