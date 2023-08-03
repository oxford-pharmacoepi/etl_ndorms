ALTER TABLE person ADD CONSTRAINT fpk_person_care_site FOREIGN KEY (care_site_id)  REFERENCES care_site (care_site_id);
