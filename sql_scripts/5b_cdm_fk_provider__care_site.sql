ALTER TABLE {TARGET_SCHEMA}.provider ADD CONSTRAINT fpk_provider_care_site FOREIGN KEY (care_site_id) REFERENCES {TARGET_SCHEMA}.care_site (care_site_id);
