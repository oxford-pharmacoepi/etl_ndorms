ALTER TABLE device_exposure ADD CONSTRAINT fpk_device_person FOREIGN KEY (person_id)  REFERENCES person (person_id);
