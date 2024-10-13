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

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.death_cause (
	eid					bigint,	
	ins_index			int,
	arr_index			int,
	level				int,
	cause_icd10			VARCHAR(8)
)TABLESPACE pg_default;
