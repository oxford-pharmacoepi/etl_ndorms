CREATE SCHEMA IF NOT EXISTS {CHUNK_SCHEMA};
--------------------------------
-- CHUNK_PERSON
--------------------------------
DROP TABLE IF EXISTS {CHUNK_SCHEMA}.chunk_person;

CREATE TABLE {CHUNK_SCHEMA}.chunk_person TABLESPACE pg_default AS 
	select (floor((row_number() over (order by person_id)-1)/{CHUNK_SIZE}) + 1)::int as chunk_id,
	person_id
	FROM {TARGET_SCHEMA}.person
	order by chunk_id, person_id;

ALTER TABLE {CHUNK_SCHEMA}.chunk_person ADD CONSTRAINT pk_chunk_person PRIMARY KEY (chunk_id, person_id) USING INDEX TABLESPACE pg_default;
CREATE UNIQUE INDEX idx_chunk_person_id ON {CHUNK_SCHEMA}.chunk_person (chunk_id, person_id ASC) TABLESPACE pg_default ;
CLUSTER {CHUNK_SCHEMA}.chunk_person USING idx_chunk_person_id;

--------------------------------
-- CHUNK
--------------------------------
DROP TABLE IF EXISTS {CHUNK_SCHEMA}.chunk;

CREATE TABLE {CHUNK_SCHEMA}.chunk TABLESPACE pg_default AS 
SELECT distinct chunk_id,
		null::varchar(20) as stem_source_tbl,
		null::varchar(20) as stem_tbl,
		null::bigint as stem_id_start,
		null::bigint as stem_id_end,
		0::smallint as completed 
FROM {CHUNK_SCHEMA}.chunk_person;

ALTER TABLE {CHUNK_SCHEMA}.chunk ADD CONSTRAINT pk_chunk PRIMARY KEY (chunk_id) USING INDEX TABLESPACE pg_default;
CREATE UNIQUE INDEX idx_chunk_id ON {CHUNK_SCHEMA}.chunk (chunk_id ASC) TABLESPACE pg_default ;
CLUSTER {CHUNK_SCHEMA}.chunk USING idx_chunk_id;
CREATE INDEX idx_chunk_completed ON {CHUNK_SCHEMA}.chunk (completed) TABLESPACE pg_default ;

---------------------------------
-- SEQUENCE for steam
---------------------------------
DROP SEQUENCE IF EXISTS {CHUNK_SCHEMA}.stem_id_seq;
CREATE SEQUENCE {CHUNK_SCHEMA}.stem_id_seq as bigint START WITH 1 INCREMENT BY 1 NO MAXVALUE CACHE 1;

--------------------------------
-- DROP TABLES CREATED BY CHUNKING
--------------------------------
truncate table {TARGET_SCHEMA}.condition_occurrence;
truncate table {TARGET_SCHEMA}.procedure_occurrence;
truncate table {TARGET_SCHEMA}.measurement;
truncate table {TARGET_SCHEMA}.device_exposure;
truncate table {TARGET_SCHEMA}.drug_exposure;
truncate table {TARGET_SCHEMA}.observation;
truncate table {TARGET_SCHEMA}.specimen;
truncate table {TARGET_SCHEMA}.episode;
truncate table {TARGET_SCHEMA}.episode_event;