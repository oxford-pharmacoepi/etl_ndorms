ALTER TABLE procedure_occurrence ADD CONSTRAINT fpk_procedure_person FOREIGN KEY (person_id)  REFERENCES person (person_id);
