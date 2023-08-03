ALTER TABLE visit_occurrence ADD CONSTRAINT fpk_visit_care_site FOREIGN KEY (care_site_id)  REFERENCES care_site (care_site_id);
