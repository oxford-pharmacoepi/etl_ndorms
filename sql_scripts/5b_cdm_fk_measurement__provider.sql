ALTER TABLE measurement ADD CONSTRAINT fpk_measurement_provider FOREIGN KEY (provider_id)  REFERENCES provider (provider_id);
