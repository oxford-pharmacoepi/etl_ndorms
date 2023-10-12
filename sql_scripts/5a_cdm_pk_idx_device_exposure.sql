ALTER TABLE {TARGET_SCHEMA}.device_exposure ADD CONSTRAINT xpk_device_exposure PRIMARY KEY (device_exposure_id);

CREATE INDEX idx_device_person_id ON {TARGET_SCHEMA}.device_exposure (person_id ASC);
CLUSTER {TARGET_SCHEMA}.device_exposure USING idx_device_person_id;
CREATE INDEX idx_device_concept_id ON {TARGET_SCHEMA}.device_exposure (device_concept_id ASC);
CREATE INDEX idx_device_visit_id ON {TARGET_SCHEMA}.device_exposure (visit_occurrence_id ASC);

