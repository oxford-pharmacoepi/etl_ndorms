ALTER TABLE {TARGET_SCHEMA}.condition_occurrence ADD CONSTRAINT xpk_condition_occurrence PRIMARY KEY (condition_occurrence_id) USING INDEX TABLESPACE pg_default;

CREATE INDEX idx_condition_person_id ON {TARGET_SCHEMA}.condition_occurrence (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.condition_occurrence USING idx_condition_person_id;
CREATE INDEX idx_condition_concept_id ON {TARGET_SCHEMA}.condition_occurrence (condition_concept_id ASC) TABLESPACE pg_default;
CREATE INDEX idx_condition_visit_id ON {TARGET_SCHEMA}.condition_occurrence (visit_occurrence_id ASC) TABLESPACE pg_default;
