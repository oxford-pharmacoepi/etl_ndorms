ALTER TABLE observation ADD CONSTRAINT fpk_observation_visit FOREIGN KEY (visit_occurrence_id)  REFERENCES visit_occurrence (visit_occurrence_id);
