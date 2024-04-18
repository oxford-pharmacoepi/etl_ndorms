CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.gp_registrations (
	eid					bigint,	
	data_provider		int,
	reg_date			date,
	deduct_date			date

)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.gp_clinical (
	eid					bigint,
	data_provider		int,
	event_dt			date,
	read_2				varchar(50),
	read_3				varchar(50),
	value1				VARCHAR(20),
	value2				VARCHAR(20),
	value3				VARCHAR(20)
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.gp_scripts (
	eid					bigint,	
	data_provider		int,
	issue_date			date,
	read_2				varchar(50),
	bnf_code			varchar(50),
	dmd_code			varchar(20),
	drug_name			varchar(500),
	quantity			varchar(10)
)TABLESPACE pg_default;