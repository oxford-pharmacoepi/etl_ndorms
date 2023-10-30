ALTER TABLE {TARGET_SCHEMA}.person ADD CONSTRAINT fpk_person_provider FOREIGN KEY (provider_id) REFERENCES {TARGET_SCHEMA}.provider (provider_id);
