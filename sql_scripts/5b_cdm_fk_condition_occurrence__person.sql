ALTER TABLE condition_occurrence ADD CONSTRAINT fpk_condition_person FOREIGN KEY (person_id)  REFERENCES person (person_id);
