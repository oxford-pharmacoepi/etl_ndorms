--ALTER TABLE {SOURCE_SCHEMA}.therapy ADD CONSTRAINT pk_therapy PRIMARY KEY(id);
--I don't think we can have another PK instead

CREATE INDEX IF NOT EXISTS idx_therapy_patid_consid ON {SOURCE_SCHEMA}.therapy (patid, consid);
CLUSTER {SOURCE_SCHEMA}.therapy USING idx_therapy_patid_consid;

CREATE INDEX IF NOT EXISTS idx_therapy_prodcode ON {SOURCE_SCHEMA}.therapy (prodcode, qty, numpacks);

CREATE INDEX IF NOT EXISTS idx_therapy_prodcode ON {SOURCE_SCHEMA}.therapy (prodcode, numpacks);

CREATE INDEX IF NOT EXISTS idx_therapy_dosageid ON {SOURCE_SCHEMA}.therapy (dosageid);

