ALTER TABLE procedure_occurrence ADD CONSTRAINT fpk_procedure_concept FOREIGN KEY (procedure_concept_id)  REFERENCES concept (concept_id);

ALTER TABLE procedure_occurrence ADD CONSTRAINT fpk_procedure_type_concept FOREIGN KEY (procedure_type_concept_id)  REFERENCES concept (concept_id);

ALTER TABLE procedure_occurrence ADD CONSTRAINT fpk_procedure_modifier FOREIGN KEY (modifier_concept_id)  REFERENCES concept (concept_id);

ALTER TABLE procedure_occurrence ADD CONSTRAINT fpk_procedure_concept_s FOREIGN KEY (procedure_source_concept_id)  REFERENCES concept (concept_id);

