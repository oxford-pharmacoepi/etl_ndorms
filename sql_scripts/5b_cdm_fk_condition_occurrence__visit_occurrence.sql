ALTER TABLE {TARGET_SCHEMA}.condition_occurrence ADD CONSTRAINT fpk_condition_visit FOREIGN KEY (visit_occurrence_id) REFERENCES {TARGET_SCHEMA}.visit_occurrence (visit_occurrence_id);
