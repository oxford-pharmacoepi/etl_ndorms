--ALTER TABLE {SOURCE_SCHEMA}.referral ADD CONSTRAINT pk_referral PRIMARY KEY(id);
--I am not sure we can have another PK instead

CREATE INDEX IF NOT EXISTS idx_ref_patid_consid ON {SOURCE_SCHEMA}.referral (patid, consid);
CLUSTER {SOURCE_SCHEMA}.referral USING idx_ref_patid_consid;

CREATE INDEX IF NOT EXISTS idx_ref_medcode ON {SOURCE_SCHEMA}.referral (medcode);
