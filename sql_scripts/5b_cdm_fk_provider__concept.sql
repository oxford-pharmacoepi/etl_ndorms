ALTER TABLE provider ADD CONSTRAINT fpk_provider_specialty FOREIGN KEY (specialty_concept_id)  REFERENCES concept (concept_id);

ALTER TABLE provider ADD CONSTRAINT fpk_provider_gender FOREIGN KEY (gender_concept_id)  REFERENCES concept (concept_id);

ALTER TABLE provider ADD CONSTRAINT fpk_provider_specialty_s FOREIGN KEY (specialty_source_concept_id)  REFERENCES concept (concept_id);

ALTER TABLE provider ADD CONSTRAINT fpk_provider_gender_s FOREIGN KEY (gender_source_concept_id)  REFERENCES concept (concept_id);
