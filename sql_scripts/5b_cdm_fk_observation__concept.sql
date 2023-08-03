ALTER TABLE observation ADD CONSTRAINT fpk_observation_concept FOREIGN KEY (observation_concept_id)  REFERENCES concept (concept_id);

ALTER TABLE observation ADD CONSTRAINT fpk_observation_type_concept FOREIGN KEY (observation_type_concept_id)  REFERENCES concept (concept_id);

ALTER TABLE observation ADD CONSTRAINT fpk_observation_value FOREIGN KEY (value_as_concept_id)  REFERENCES concept (concept_id);

ALTER TABLE observation ADD CONSTRAINT fpk_observation_qualifier FOREIGN KEY (qualifier_concept_id)  REFERENCES concept (concept_id);

ALTER TABLE observation ADD CONSTRAINT fpk_observation_unit FOREIGN KEY (unit_concept_id)  REFERENCES concept (concept_id);

ALTER TABLE observation ADD CONSTRAINT fpk_observation_concept_s FOREIGN KEY (observation_source_concept_id)  REFERENCES concept (concept_id);
