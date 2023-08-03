ALTER TABLE drug_exposure ADD CONSTRAINT fpk_drug_provider FOREIGN KEY (provider_id)  REFERENCES provider (provider_id);
