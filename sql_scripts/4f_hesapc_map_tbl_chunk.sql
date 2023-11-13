CREATE SCHEMA IF NOT EXISTS {CHUNK_SCHEMA};
--------------------------------
-- CHUNK_PERSON
--------------------------------
DROP TABLE IF EXISTS {CHUNK_SCHEMA}.chunk_person;

CREATE TABLE {CHUNK_SCHEMA}.chunk_person AS 
	select (floor((row_number() over (order by person_id)-1)/{CHUNK_SIZE}) + 1)::int as chunk_id,
	person_id
	FROM {TARGET_SCHEMA}.person
	order by chunk_id, person_id;

ALTER TABLE {CHUNK_SCHEMA}.chunk_person ADD CONSTRAINT pk_chunk_person PRIMARY KEY (chunk_id, person_id);
CREATE UNIQUE INDEX idx_chunk_person_id ON {CHUNK_SCHEMA}.chunk_person (chunk_id, person_id ASC);
CLUSTER {CHUNK_SCHEMA}.chunk_person USING idx_chunk_person_id;

--------------------------------
-- CHUNK
--------------------------------
DROP TABLE IF EXISTS {CHUNK_SCHEMA}.chunk;

CREATE TABLE {CHUNK_SCHEMA}.chunk AS 
SELECT distinct chunk_id,
		null::varchar(20) as stem_source_tbl,
		null::varchar(20) as stem_tbl,
		null::bigint as stem_id_start,
		null::bigint as stem_id_end,
		0::smallint as completed 
FROM {CHUNK_SCHEMA}.chunk_person;

ALTER TABLE {CHUNK_SCHEMA}.chunk ADD CONSTRAINT pk_chunk PRIMARY KEY (chunk_id);
CREATE UNIQUE INDEX idx_chunk_id ON {CHUNK_SCHEMA}.chunk (chunk_id ASC);
CLUSTER {CHUNK_SCHEMA}.chunk USING idx_chunk_id;
CREATE INDEX idx_chunk_completed ON {CHUNK_SCHEMA}.chunk (completed);

--------------------------------
-- _RECORDS
--------------------------------
drop table if exists {TARGET_SCHEMA}._records CASCADE;
create table {TARGET_SCHEMA}._records (
	tbl_name varchar(25) NOT NULL,
	{TARGET_SCHEMA}_records bigint DEFAULT 0,
	{TARGET_SCHEMA}_nok_records bigint DEFAULT 0,
	total_records bigint DEFAULT 0
);


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
