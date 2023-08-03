ALTER TABLE care_site ADD CONSTRAINT fpk_care_site_location FOREIGN KEY (location_id)  REFERENCES location (location_id);
