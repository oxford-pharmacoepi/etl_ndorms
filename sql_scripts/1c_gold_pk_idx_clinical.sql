--ALTER TABLE {SOURCE_SCHEMA}.clinical ADD CONSTRAINT pk_clinical PRIMARY KEY(id);
--I don't think we can have another PK instead

CREATE INDEX IF NOT EXISTS idx_clin_patid_consid ON {SOURCE_SCHEMA}.clinical (patid, consid) TABLESPACE pg_default;
CLUSTER {SOURCE_SCHEMA}.clinical USING idx_clin_patid_consid;

CREATE INDEX IF NOT EXISTS idx_clin_adid ON {SOURCE_SCHEMA}.clinical (patid, adid) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_clin_medcode ON {SOURCE_SCHEMA}.clinical (medcode) TABLESPACE pg_default;