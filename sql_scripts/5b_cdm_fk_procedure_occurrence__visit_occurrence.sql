ALTER TABLE {TARGET_SCHEMA}.procedure_occurrence ADD CONSTRAINT fpk_procedure_visit FOREIGN KEY (visit_occurrence_id) REFERENCES {TARGET_SCHEMA}.visit_occurrence (visit_occurrence_id);
