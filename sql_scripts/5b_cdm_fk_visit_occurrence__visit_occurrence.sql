ALTER TABLE visit_occurrence ADD CONSTRAINT fpk_visit_preceding FOREIGN KEY (preceding_visit_occurrence_id) REFERENCES visit_occurrence (visit_occurrence_id);
