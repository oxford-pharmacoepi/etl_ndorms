ALTER TABLE {TARGET_SCHEMA}.location ADD CONSTRAINT xpk_location PRIMARY KEY (location_id);

CREATE INDEX idx_location_id_1  ON {TARGET_SCHEMA}.location  (location_id ASC); 	-- Added by Teen
CLUSTER {TARGET_SCHEMA}.location  USING idx_location_id_1 ; 						-- Added by Teen
