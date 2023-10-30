ALTER TABLE {TARGET_SCHEMA}.measurement ADD CONSTRAINT fpk_measurement_visit FOREIGN KEY (visit_occurrence_id) REFERENCES {TARGET_SCHEMA}.visit_occurrence (visit_occurrence_id);

