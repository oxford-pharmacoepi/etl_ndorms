ALTER TABLE device_exposure ADD CONSTRAINT fpk_device_provider FOREIGN KEY (provider_id)  REFERENCES provider (provider_id);
