ALTER TABLE {TARGET_SCHEMA}.device_exposure ADD CONSTRAINT fpk_device_provider FOREIGN KEY (provider_id) REFERENCES {TARGET_SCHEMA}.provider (provider_id);
