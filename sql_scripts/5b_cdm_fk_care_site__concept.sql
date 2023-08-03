ALTER TABLE care_site ADD CONSTRAINT fpk_care_site_place FOREIGN KEY (place_of_service_concept_id)  REFERENCES concept (concept_id);

