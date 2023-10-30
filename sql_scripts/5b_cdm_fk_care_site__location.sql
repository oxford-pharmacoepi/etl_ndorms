ALTER TABLE {TARGET_SCHEMA}.care_site ADD CONSTRAINT fpk_care_site_location FOREIGN KEY (location_id) REFERENCES {TARGET_SCHEMA}.location (location_id);
