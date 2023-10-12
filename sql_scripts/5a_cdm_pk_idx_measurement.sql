ALTER TABLE {TARGET_SCHEMA}.measurement ADD CONSTRAINT xpk_measurement PRIMARY KEY (measurement_id);

CREATE INDEX idx_measurement_person_id ON {TARGET_SCHEMA}.measurement (person_id ASC);
CLUSTER {TARGET_SCHEMA}.measurement USING idx_measurement_person_id;
CREATE INDEX idx_measurement_concept_id ON {TARGET_SCHEMA}.measurement (measurement_concept_id ASC);
CREATE INDEX idx_measurement_visit_id ON {TARGET_SCHEMA}.measurement (visit_occurrence_id ASC);
