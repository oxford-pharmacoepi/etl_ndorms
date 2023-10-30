ALTER TABLE {TARGET_SCHEMA}.visit_detail ADD CONSTRAINT fpk_v_detail_care_site FOREIGN KEY (care_site_id) REFERENCES {TARGET_SCHEMA}.care_site (care_site_id);
