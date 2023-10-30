ALTER TABLE {TARGET_SCHEMA}.drug_exposure ADD CONSTRAINT fpk_drug_provider FOREIGN KEY (provider_id) REFERENCES {TARGET_SCHEMA}.provider (provider_id);
