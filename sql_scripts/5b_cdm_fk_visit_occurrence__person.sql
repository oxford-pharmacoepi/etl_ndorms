ALTER TABLE visit_occurrence ADD CONSTRAINT fpk_visit_person FOREIGN KEY (person_id)  REFERENCES person (person_id);
