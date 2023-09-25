--ALTER TABLE {SOURCE_SCHEMA}.immunisation ADD CONSTRAINT pk_immunisation PRIMARY KEY(id);
--I don't think we can have another PK instead

CREATE INDEX IF NOT EXISTS idx_imm_patid_consid ON {SOURCE_SCHEMA}.immunisation (patid, consid);
CLUSTER {SOURCE_SCHEMA}.immunisation USING idx_imm_patid_consid;

CREATE INDEX IF NOT EXISTS idx_imm_medcode ON {SOURCE_SCHEMA}.immunisation (medcode);