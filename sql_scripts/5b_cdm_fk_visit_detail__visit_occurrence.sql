ALTER TABLE visit_detail ADD CONSTRAINT fpk_v_detail_visit FOREIGN KEY (visit_occurrence_id) REFERENCES visit_occurrence (visit_occurrence_id);
