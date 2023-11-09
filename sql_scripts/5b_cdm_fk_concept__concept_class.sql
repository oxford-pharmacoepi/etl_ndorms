ALTER TABLE {VOCABULARY_SCHEMA}.concept ADD CONSTRAINT fpk_concept_concept_class_id FOREIGN KEY (concept_class_id) REFERENCES {VOCABULARY_SCHEMA}.concept_class (concept_class_id);
