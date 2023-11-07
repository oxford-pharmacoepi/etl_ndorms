ALTER TABLE {TARGET_SCHEMA}.provider ADD CONSTRAINT xpk_provider PRIMARY KEY (provider_id);

CREATE INDEX idx_provider_id_1  ON {TARGET_SCHEMA}.provider  (provider_id ASC); -- Added by Teen
CLUSTER {TARGET_SCHEMA}.provider  USING idx_provider_id_1 ;						-- Added by Teen