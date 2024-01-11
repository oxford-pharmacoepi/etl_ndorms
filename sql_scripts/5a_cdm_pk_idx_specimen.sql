ALTER TABLE {TARGET_SCHEMA}.SPECIMEN ADD CONSTRAINT xpk_SPECIMEN PRIMARY KEY (specimen_id) USING INDEX TABLESPACE pg_default;

CREATE INDEX idx_specimen_person_id_1 ON {TARGET_SCHEMA}.specimen (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.specimen USING idx_specimen_person_id_1;
CREATE INDEX idx_specimen_concept_id_1 ON {TARGET_SCHEMA}.specimen (specimen_concept_id ASC) TABLESPACE pg_default;
