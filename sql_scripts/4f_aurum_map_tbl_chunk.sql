CREATE SCHEMA IF NOT EXISTS CHUNKS;
--------------------------------
-- CHUNK_PERSON
--------------------------------
DROP TABLE IF EXISTS chunks.chunk_person;

CREATE TABLE chunks.chunk_person AS 
	select (floor((row_number() over (order by person_id)-1)/{CHUNK_SIZE}) + 1)::int as chunk_id,
	person_id
	FROM {TARGET_SCHEMA}.person
	order by chunk_id, person_id;

ALTER TABLE chunks.chunk_person ADD CONSTRAINT pk_chunk_person PRIMARY KEY (chunk_id, person_id);
CREATE UNIQUE INDEX idx_chunk_person_id ON chunks.chunk_person (chunk_id, person_id ASC);
CLUSTER chunks.chunk_person USING idx_chunk_person_id;

--------------------------------
-- CHUNK
--------------------------------
DROP TABLE IF EXISTS chunks.chunk;

CREATE TABLE chunks.chunk AS 
SELECT distinct chunk_id,
		null::varchar(20) as stem_source_tbl,
		null::varchar(20) as stem_tbl,
		null::bigint as stem_id_start,
		null::bigint as stem_id_end,
		0::smallint as completed 
FROM chunks.chunk_person;

ALTER TABLE chunks.chunk ADD CONSTRAINT pk_chunk PRIMARY KEY (chunk_id);
CREATE UNIQUE INDEX idx_chunk_id ON chunks.chunk (chunk_id ASC);
CLUSTER chunks.chunk USING idx_chunk_id;
CREATE INDEX idx_chunk_completed ON chunks.chunk (completed);

--------------------------------
-- DROP TABLES CREATED BY CHUNKING
--------------------------------
--drop table if exists {TARGET_SCHEMA}.stem_source CASCADE;	--We do not use it anymore, but need it as template for smaller tables
--drop table if exists {TARGET_SCHEMA}.stem CASCADE;		--We do not use it anymore, but need it as template for smaller tables
truncate table {TARGET_SCHEMA}.condition_occurrence;
truncate table {TARGET_SCHEMA}.procedure_occurrence;
truncate table {TARGET_SCHEMA}.measurement;
truncate table {TARGET_SCHEMA}.device_exposure;
truncate table {TARGET_SCHEMA}.drug_exposure;
truncate table {TARGET_SCHEMA}.observation;
truncate table {TARGET_SCHEMA}.specimen;
