ALTER TABLE {TARGET_SCHEMA}.episode_event ADD CONSTRAINT xpk_episode_event PRIMARY KEY (episode_id, event_id) USING INDEX TABLESPACE pg_default;
