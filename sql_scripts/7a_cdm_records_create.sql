drop table if exists {TARGET_SCHEMA}._records CASCADE;

create table {TARGET_SCHEMA}._records (
	tbl_name varchar(25) NOT NULL,
	total_records bigint DEFAULT 0
)TABLESPACE pg_default;