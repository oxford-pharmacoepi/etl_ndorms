ALTER TABLE METADATA ADD CONSTRAINT xpk_METADATA PRIMARY KEY (metadata_concept_id);
CREATE INDEX idx_metadata_concept_id_1 ON metadata  (metadata_concept_id ASC);
CLUSTER metadata USING idx_metadata_concept_id_1 ;
