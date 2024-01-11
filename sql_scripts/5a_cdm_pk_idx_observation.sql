ALTER TABLE {TARGET_SCHEMA}.observation ADD CONSTRAINT xpk_observation PRIMARY KEY (observation_id) USING INDEX TABLESPACE pg_default;

CREATE INDEX idx_observation_person_id ON {TARGET_SCHEMA}.observation (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.observation USING idx_observation_person_id;
CREATE INDEX idx_observation_concept_id ON {TARGET_SCHEMA}.observation (observation_concept_id ASC) TABLESPACE pg_default;
CREATE INDEX idx_observation_visit_id ON {TARGET_SCHEMA}.observation (visit_occurrence_id ASC) TABLESPACE pg_default;

