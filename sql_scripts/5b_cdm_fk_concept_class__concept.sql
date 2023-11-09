ALTER TABLE {VOCABULARY_SCHEMA}.concept_class ADD CONSTRAINT fpk_concept_class_concept_class_concept_id FOREIGN KEY (concept_class_concept_id) REFERENCES {VOCABULARY_SCHEMA}.concept (concept_id);
