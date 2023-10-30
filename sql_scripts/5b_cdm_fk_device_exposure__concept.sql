ALTER TABLE {TARGET_SCHEMA}.device_exposure ADD CONSTRAINT fpk_device_concept FOREIGN KEY (device_concept_id) REFERENCES {VOCABULARY_SCHEMA}.concept (concept_id);
ALTER TABLE {TARGET_SCHEMA}.device_exposure ADD CONSTRAINT fpk_device_type_concept FOREIGN KEY (device_type_concept_id) REFERENCES {VOCABULARY_SCHEMA}.concept (concept_id);
ALTER TABLE {TARGET_SCHEMA}.device_exposure ADD CONSTRAINT fpk_device_concept_s FOREIGN KEY (device_source_concept_id) REFERENCES {VOCABULARY_SCHEMA}.concept (concept_id);
