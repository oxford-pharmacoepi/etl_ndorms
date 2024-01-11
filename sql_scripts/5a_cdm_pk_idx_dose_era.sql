ALTER TABLE {TARGET_SCHEMA}.DOSE_ERA ADD CONSTRAINT xpk_DOSE_ERA PRIMARY KEY (dose_era_id) USING INDEX TABLESPACE pg_default;

CREATE INDEX idx_dose_era_person_id_1  ON {TARGET_SCHEMA}.dose_era (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.dose_era USING idx_dose_era_person_id_1;
CREATE INDEX idx_dose_era_concept_id_1 ON {TARGET_SCHEMA}.dose_era (drug_concept_id ASC) TABLESPACE pg_default;
