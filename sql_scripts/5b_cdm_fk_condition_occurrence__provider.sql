ALTER TABLE {TARGET_SCHEMA}.condition_occurrence ADD CONSTRAINT fpk_condition_provider FOREIGN KEY (provider_id) REFERENCES {TARGET_SCHEMA}.provider (provider_id);
