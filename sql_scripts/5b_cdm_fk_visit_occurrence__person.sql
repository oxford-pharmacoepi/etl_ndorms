ALTER TABLE {TARGET_SCHEMA}.visit_occurrence ADD CONSTRAINT fpk_visit_person FOREIGN KEY (person_id) REFERENCES {TARGET_SCHEMA}.person (person_id);
