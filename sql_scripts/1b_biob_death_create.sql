CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.death_row1 (
	eid					bigint,	
	ins_index			int,
	dsource				VARCHAR(4),
	source				int,
	date_of_death		date
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.death_cause_row1 (
	eid					bigint,	
	ins_index			int,
	arr_index			int,
	level				int,
	cause_icd10			VARCHAR(8)
)TABLESPACE pg_default;