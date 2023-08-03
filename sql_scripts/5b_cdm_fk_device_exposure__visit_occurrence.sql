ALTER TABLE device_exposure ADD CONSTRAINT fpk_device_visit FOREIGN KEY (visit_occurrence_id)  REFERENCES visit_occurrence (visit_occurrence_id);
