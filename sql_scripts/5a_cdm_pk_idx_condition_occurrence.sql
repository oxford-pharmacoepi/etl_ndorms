ALTER TABLE {TARGET_SCHEMA}.condition_occurrence ADD CONSTRAINT xpk_condition_occurrence PRIMARY KEY (condition_occurrence_id);

CREATE INDEX idx_condition_person_id ON {TARGET_SCHEMA}.condition_occurrence (person_id ASC);
CLUSTER {TARGET_SCHEMA}.condition_occurrence USING idx_condition_person_id;
CREATE INDEX idx_condition_concept_id ON {TARGET_SCHEMA}.condition_occurrence (condition_concept_id ASC);
CREATE INDEX idx_condition_visit_id ON {TARGET_SCHEMA}.condition_occurrence (visit_occurrence_id ASC);
