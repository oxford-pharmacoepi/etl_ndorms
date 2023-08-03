ALTER TABLE condition_occurrence ADD CONSTRAINT fpk_condition_provider FOREIGN KEY (provider_id)  REFERENCES provider (provider_id);
