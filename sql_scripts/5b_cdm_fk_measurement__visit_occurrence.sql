ALTER TABLE measurement ADD CONSTRAINT fpk_measurement_visit FOREIGN KEY (visit_occurrence_id)  REFERENCES visit_occurrence (visit_occurrence_id);

