ALTER TABLE procedure_occurrence ADD CONSTRAINT fpk_procedure_provider FOREIGN KEY (provider_id)  REFERENCES provider (provider_id);
