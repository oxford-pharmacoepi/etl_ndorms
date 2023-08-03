ALTER TABLE observation ADD CONSTRAINT fpk_observation_provider FOREIGN KEY (provider_id)  REFERENCES provider (provider_id);
