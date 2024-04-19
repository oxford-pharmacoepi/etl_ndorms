---Creating covid19_result_england_row1 Table ---------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.covid19_result_england_row1(
	eid					bigint,
	specdate			date,
	spectype			int,
	laboratory			int,
	origin				int,
	result				int,
	acute				int,
	hosaq				int,
	reqorg				int)
	TABLESPACE pg_default;
	
---Creating covid19_result_scotland_row1 Table ---------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.covid19_result_scotland_row1 (
	eid					bigint,
	specdate			date,
	laboratory			varchar(10),
	source				int,
	locauth				int,
	result				int)
	TABLESPACE pg_default;

---Creating covid19_result_wales_row1 Table ---------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.covid19_result_wales_row1 (
	eid					bigint,
	specdate			date,
	spectype			int,
	laboratory			int,
	pattype				int,
	perstype			int,
	result				int)
	TABLESPACE pg_default;

---Creating covid19_vaccination_row1 Table ---------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.covid19_vaccination_row1 (
	eid					bigint,
	source				varchar(10),
	vacc_date			date,
	product				varchar(10),
	procedure			varchar(10),
	procedure_uni		varchar(10))
	TABLESPACE pg_default;

---Creating covid19_misc_row1 Table ---------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.covid19_misc_row1 (
	eid					bigint,
	blood_group			varchar(10))
	TABLESPACE pg_default;