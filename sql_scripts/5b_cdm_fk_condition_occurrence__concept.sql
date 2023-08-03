ALTER TABLE condition_occurrence ADD CONSTRAINT fpk_condition_concept FOREIGN KEY (condition_concept_id)  REFERENCES concept (concept_id);

ALTER TABLE condition_occurrence ADD CONSTRAINT fpk_condition_type_concept FOREIGN KEY (condition_type_concept_id)  REFERENCES concept (concept_id);

ALTER TABLE condition_occurrence ADD CONSTRAINT fpk_condition_status_concept FOREIGN KEY (condition_status_concept_id) REFERENCES concept (concept_id);

ALTER TABLE condition_occurrence ADD CONSTRAINT fpk_condition_concept_s FOREIGN KEY (condition_source_concept_id)  REFERENCES concept (concept_id);
