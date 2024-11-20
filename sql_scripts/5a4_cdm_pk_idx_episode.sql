ALTER TABLE {TARGET_SCHEMA}.episode ADD CONSTRAINT xpk_episode PRIMARY KEY (episode_id) USING INDEX TABLESPACE pg_default;
CREATE INDEX idx_episode_concept_id ON {TARGET_SCHEMA}.episode (episode_concept_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.episode USING idx_episode_concept_id;
