ALTER TABLE {TARGET_SCHEMA}.visit_detail ADD CONSTRAINT fpk_v_detail_provider FOREIGN KEY (provider_id) REFERENCES {TARGET_SCHEMA}.provider (provider_id);
