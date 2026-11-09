-- PK should be (patid, attendid), but the data are dirty and we added a dummy PK
ALTER table {SOURCE_SCHEMA}.rtds_episode add constraint pk_rtds_episode primary key (episode_id) USING INDEX TABLESPACE pg_default;

CREATE INDEX idx_rtds_episode ON {SOURCE_SCHEMA}.rtds_episode (patid, attendid  ASC) TABLESPACE pg_default;
CLUSTER {SOURCE_SCHEMA}.rtds_episode USING idx_rtds_episode;
