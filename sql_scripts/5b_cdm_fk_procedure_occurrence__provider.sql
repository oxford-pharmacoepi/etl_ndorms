ALTER TABLE {TARGET_SCHEMA}.procedure_occurrence ADD CONSTRAINT fpk_procedure_provider FOREIGN KEY (provider_id) REFERENCES {TARGET_SCHEMA}.provider (provider_id);
