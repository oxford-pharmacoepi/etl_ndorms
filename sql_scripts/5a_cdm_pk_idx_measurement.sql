ALTER TABLE measurement ADD CONSTRAINT xpk_measurement PRIMARY KEY ( measurement_id ) ;

CREATE INDEX idx_measurement_person_id ON measurement (person_id ASC);
CLUSTER measurement USING idx_measurement_person_id;
CREATE INDEX idx_measurement_concept_id ON measurement (measurement_concept_id ASC);
CREATE INDEX idx_measurement_visit_id ON measurement (visit_occurrence_id ASC);
