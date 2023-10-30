ALTER TABLE {TARGET_SCHEMA}.procedure_occurrence ADD CONSTRAINT fpk_procedure_person FOREIGN KEY (person_id) REFERENCES {TARGET_SCHEMA}.person (person_id);
