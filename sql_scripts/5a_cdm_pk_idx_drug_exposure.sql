ALTER TABLE {TARGET_SCHEMA}.drug_exposure ADD CONSTRAINT xpk_drug_exposure PRIMARY KEY (drug_exposure_id);

CREATE INDEX idx_drug_person_id  ON {TARGET_SCHEMA}.drug_exposure (person_id ASC);
CLUSTER {TARGET_SCHEMA}.drug_exposure  USING idx_drug_person_id;
CREATE INDEX idx_drug_concept_id ON {TARGET_SCHEMA}.drug_exposure (drug_concept_id ASC);
CREATE INDEX idx_drug_visit_id ON {TARGET_SCHEMA}.drug_exposure (visit_occurrence_id ASC);
