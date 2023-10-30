ALTER TABLE {TARGET_SCHEMA}.care_site ADD CONSTRAINT fpk_care_site_place FOREIGN KEY (place_of_service_concept_id) REFERENCES {VOCABULARY_SCHEMA}.concept (concept_id);

