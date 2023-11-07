ALTER TABLE {TARGET_SCHEMA}.care_site ADD CONSTRAINT xpk_care_site PRIMARY KEY (care_site_id);

CREATE INDEX idx_care_site_id_1  ON {TARGET_SCHEMA}.care_site  (care_site_id ASC);	-- Added by Teen
CLUSTER {TARGET_SCHEMA}.care_site  USING idx_care_site_id_1 ;						-- Added by Teen