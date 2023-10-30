ALTER TABLE {TARGET_SCHEMA}.condition_occurrence ADD CONSTRAINT fpk_condition_person FOREIGN KEY (person_id) REFERENCES {TARGET_SCHEMA}.person (person_id);
