ALTER TABLE {TARGET_SCHEMA}.drug_exposure ADD CONSTRAINT fpk_drug_person FOREIGN KEY (person_id) REFERENCES {TARGET_SCHEMA}.person (person_id);
