ALTER TABLE {VOCABULARY_SCHEMA}.DOMAIN ADD CONSTRAINT fpk_domain_domain_concept_id FOREIGN KEY (domain_concept_id) REFERENCES {VOCABULARY_SCHEMA}.concept (concept_id);
