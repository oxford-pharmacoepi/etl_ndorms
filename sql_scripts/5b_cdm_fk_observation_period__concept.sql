ALTER TABLE {TARGET_SCHEMA}.observation_period ADD CONSTRAINT fpk_observation_period_concept FOREIGN KEY (period_type_concept_id) REFERENCES {VOCABULARY_SCHEMA}.concept (concept_id);
