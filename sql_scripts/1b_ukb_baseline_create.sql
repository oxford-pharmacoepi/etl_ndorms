CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.baseline (
	eid				bigint 		not null, --patientID	
	p31				smallint, --Sex
	p34				smallint, --Year of birth
	p52				smallint, --Month of birth
	p53_i0			date, --Date of attending assessment centre
	p53_i1			date, --Date of attending assessment centre
	p53_i2			date, --Date of attending assessment centre
	p53_i3			date, --Date of attending assessment centre
	p54_i0			NUMERIC, --UK Biobank assessment centre
	p54_i1			NUMERIC, --UK Biobank assessment centre
	p54_i2			NUMERIC, --UK Biobank assessment centre
	p54_i3			NUMERIC, --UK Biobank assessment centre
	p200			date, --Date of consenting to join UK Biobank	
	p20143			date, --Date of last personal contact with UK Biobank
	p21000_i0		NUMERIC, --Ethnic background
	p21000_i1		NUMERIC, --Ethnic background
	p21000_i2		NUMERIC, --Ethnic background
	p21000_i3		NUMERIC, --Ethnic background
	p21022			int, --Age at recruitment
	p22189			NUMERIC, --Townsend deprivation index at recruitment
	p26410			NUMERIC, --Index of Multiple Deprivation (England)
	p26426			NUMERIC, --	Index of Multiple Deprivation (Wales)
	p26427			NUMERIC --	Index of Multiple Deprivation (Scotland)
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


CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}._patid_deleted (
	patid			bigint 		not null,	
	reason			VARCHAR(1)
)TABLESPACE pg_default;