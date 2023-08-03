ALTER TABLE condition_occurrence ADD CONSTRAINT fpk_condition_visit FOREIGN KEY (visit_occurrence_id)  REFERENCES visit_occurrence (visit_occurrence_id);
