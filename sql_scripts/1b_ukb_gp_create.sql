CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.baseline (
	eid				bigint 		not null,	
	p31				smallint,
	p34				smallint,
	p52				smallint,
	p53_i0			date,
	p53_i1			date,
	p53_i2			date,
	p53_i3			date,
	p54_i0			NUMERIC,
	p54_i1			NUMERIC,
	p54_i2			NUMERIC,
	p54_i3			NUMERIC,
	p200			date,
	p20143			date,
	p21000_i0		NUMERIC,
	p21000_i1		NUMERIC,
	p21000_i2		NUMERIC,
	p21000_i3		NUMERIC,
	p21022			int,
	p22189			NUMERIC,
	p26410			NUMERIC,
	p26426			NUMERIC,
	p26427			NUMERIC
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.death (
	eid					bigint,	
	ins_index			int,
	dsource				VARCHAR(4),
	source				int,
	date_of_death		date
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.gp_registrations (
	eid					bigint,	
	data_provider		int,
	reg_date			date,
	deduct_date			date

)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.gp_clinical (
	id					BIGSERIAL 	NOT NULL,
	eid					bigint,
	data_provider		int,
	event_dt			date,
	read_2				varchar(7),
	read_3				varchar(7),
	value1				VARCHAR(800),
	value2				VARCHAR(800),
	value3				VARCHAR(800)
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.gp_scripts (
	id					BIGSERIAL 	NOT NULL,
	eid					bigint,	
	data_provider		int,
	issue_date			date,
	read_2				varchar(7),
	bnf_code			varchar(15),
	dmd_code			varchar(20),
	drug_name			varchar(600),
	quantity			varchar(250)
)TABLESPACE pg_default;