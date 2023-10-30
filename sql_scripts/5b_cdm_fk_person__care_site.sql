ALTER TABLE {TARGET_SCHEMA}.person ADD CONSTRAINT fpk_person_care_site FOREIGN KEY (care_site_id) REFERENCES {TARGET_SCHEMA}.care_site (care_site_id);
