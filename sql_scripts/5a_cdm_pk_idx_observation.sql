ALTER TABLE observation ADD CONSTRAINT xpk_observation PRIMARY KEY ( observation_id ) ;

CREATE INDEX idx_observation_person_id ON observation (person_id ASC);
CLUSTER observation  USING idx_observation_person_id ;
CREATE INDEX idx_observation_concept_id ON observation (observation_concept_id ASC);
CREATE INDEX idx_observation_visit_id ON observation (visit_occurrence_id ASC);

