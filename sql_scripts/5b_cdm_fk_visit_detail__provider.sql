ALTER TABLE visit_detail ADD CONSTRAINT fpk_v_detail_provider FOREIGN KEY (provider_id)  REFERENCES provider (provider_id);
