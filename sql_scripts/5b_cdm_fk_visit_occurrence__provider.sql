ALTER TABLE {TARGET_SCHEMA}.visit_occurrence ADD CONSTRAINT fpk_visit_provider FOREIGN KEY (provider_id) REFERENCES {TARGET_SCHEMA}.provider (provider_id);
