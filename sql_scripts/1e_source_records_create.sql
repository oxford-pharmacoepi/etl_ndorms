drop table if exists {SOURCE_SCHEMA}._records CASCADE;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}._records (
	tbl_name 					varchar(30) NOT NULL,
	{SOURCE_SCHEMA}_records 	bigint DEFAULT 0,
	{SOURCE_NOK_SCHEMA}_records bigint DEFAULT 0,
	total_records 				bigint DEFAULT 0)
TABLESPACE pg_default;
