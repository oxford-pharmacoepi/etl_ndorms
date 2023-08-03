ALTER TABLE visit_occurrence ADD CONSTRAINT fpk_visit_provider FOREIGN KEY (provider_id)  REFERENCES provider (provider_id);
