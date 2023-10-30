ALTER TABLE {TARGET_SCHEMA}.drug_exposure ADD CONSTRAINT fpk_drug_visit FOREIGN KEY (visit_occurrence_id) REFERENCES {TARGET_SCHEMA}.visit_occurrence (visit_occurrence_id);
