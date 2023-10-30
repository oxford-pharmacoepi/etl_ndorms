ALTER TABLE {TARGET_SCHEMA}.drug_exposure ADD CONSTRAINT fpk_drug_concept FOREIGN KEY (drug_concept_id) REFERENCES {VOCABULARY_SCHEMA}.concept (concept_id);
ALTER TABLE {TARGET_SCHEMA}.drug_exposure ADD CONSTRAINT fpk_drug_type_concept FOREIGN KEY (drug_type_concept_id) REFERENCES {VOCABULARY_SCHEMA}.concept (concept_id);
ALTER TABLE {TARGET_SCHEMA}.drug_exposure ADD CONSTRAINT fpk_drug_route_concept FOREIGN KEY (route_concept_id) REFERENCES {VOCABULARY_SCHEMA}.concept (concept_id);
ALTER TABLE {TARGET_SCHEMA}.drug_exposure ADD CONSTRAINT fpk_drug_concept_s FOREIGN KEY (drug_source_concept_id) REFERENCES {VOCABULARY_SCHEMA}.concept (concept_id);
