ALTER TABLE {TARGET_SCHEMA}.procedure_occurrence ADD CONSTRAINT xpk_procedure_occurrence PRIMARY KEY (procedure_occurrence_id);

CREATE INDEX idx_procedure_person_id ON {TARGET_SCHEMA}.procedure_occurrence (person_id ASC);
CLUSTER {TARGET_SCHEMA}.procedure_occurrence USING idx_procedure_person_id;
CREATE INDEX idx_procedure_concept_id ON {TARGET_SCHEMA}.procedure_occurrence (procedure_concept_id ASC);
CREATE INDEX idx_procedure_visit_id ON {TARGET_SCHEMA}.procedure_occurrence (visit_occurrence_id ASC);
