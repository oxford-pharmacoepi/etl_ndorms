ALTER TABLE {TARGET_SCHEMA}.NOTE ADD CONSTRAINT fpk_NOTE_person_id FOREIGN KEY (person_id) REFERENCES {TARGET_SCHEMA}.PERSON (PERSON_ID);
