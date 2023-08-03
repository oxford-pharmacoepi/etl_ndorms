ALTER TABLE visit_detail ADD CONSTRAINT fpk_v_detail_care_site FOREIGN KEY (care_site_id)  REFERENCES care_site (care_site_id);
