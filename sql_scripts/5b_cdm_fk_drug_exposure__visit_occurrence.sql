ALTER TABLE drug_exposure ADD CONSTRAINT fpk_drug_visit FOREIGN KEY (visit_occurrence_id)  REFERENCES visit_occurrence (visit_occurrence_id);
