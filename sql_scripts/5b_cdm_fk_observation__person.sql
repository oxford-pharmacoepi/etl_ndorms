ALTER TABLE observation ADD CONSTRAINT fpk_observation_person FOREIGN KEY (person_id)  REFERENCES person (person_id);
