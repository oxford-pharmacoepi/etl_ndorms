ALTER TABLE {TARGET_SCHEMA}.measurement ADD CONSTRAINT fpk_measurement_provider FOREIGN KEY (provider_id) REFERENCES {TARGET_SCHEMA}.provider (provider_id);
