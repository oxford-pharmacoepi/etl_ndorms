ALTER TABLE {TARGET_SCHEMA}.visit_occurrence ADD CONSTRAINT fpk_visit_preceding FOREIGN KEY (preceding_visit_occurrence_id) REFERENCES {TARGET_SCHEMA}.visit_occurrence (visit_occurrence_id);
