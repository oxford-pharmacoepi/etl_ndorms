ALTER TABLE observation_period ADD CONSTRAINT fpk_observation_period_concept FOREIGN KEY (period_type_concept_id)  REFERENCES concept (concept_id);
