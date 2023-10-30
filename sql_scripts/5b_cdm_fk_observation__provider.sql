ALTER TABLE {TARGET_SCHEMA}.observation ADD CONSTRAINT fpk_observation_provider FOREIGN KEY (provider_id) REFERENCES {TARGET_SCHEMA}.provider (provider_id);
