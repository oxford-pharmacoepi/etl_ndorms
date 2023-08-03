ALTER TABLE observation_period ADD CONSTRAINT fpk_observation_period_person FOREIGN KEY (person_id)  REFERENCES person (person_id);
