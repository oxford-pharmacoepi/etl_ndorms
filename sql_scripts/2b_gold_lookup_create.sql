CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.batchnumber
(
	batch bigint NOT NULL,
	batch_number varchar(200) DEFAULT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.bnfcodes
(
	bnfcode	int NOT NULL,
	bnf varchar(8) DEFAULT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.common_dosages
(
	dosageid varchar(64) NOT NULL,
	dosage_text varchar(1000) DEFAULT NULL,
	daily_dose numeric(15,3) DEFAULT NULL,
	dose_number numeric(15,3) DEFAULT NULL,
	dose_unit varchar(7) DEFAULT NULL,
	dose_frequency numeric(15,3) DEFAULT NULL,
	dose_interval numeric(15,3) DEFAULT NULL,
	choice_of_dose smallint,
	dose_max_average smallint,
	change_dose smallint,
	dose_duration numeric(15,3) DEFAULT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.entity
(
	enttype integer NOT NULL,
	description varchar(60) NOT NULL,
	filetype varchar(8) NOT NULL,
	category varchar(30) DEFAULT NULL,
	data_fields smallint NOT NULL,
	data1 varchar(50) DEFAULT NULL,
	data1_lkup varchar(20) DEFAULT NULL,
	data2 varchar(50) DEFAULT NULL,
	data2_lkup varchar(20) DEFAULT NULL,
	data3 varchar(50) DEFAULT NULL,
	data3_lkup varchar(20) DEFAULT NULL,
	data4 varchar(50) DEFAULT NULL,
	data4_lkup varchar(20) DEFAULT NULL,
	data5 varchar(50) DEFAULT NULL,
	data5_lkup varchar(20) DEFAULT NULL,
	data6 varchar(50) DEFAULT NULL,
	data6_lkup varchar(20) DEFAULT NULL,
	data7 varchar(50) DEFAULT NULL,
	data7_lkup varchar(20) DEFAULT NULL,
	data8 varchar(50) DEFAULT NULL,
	data8_lkup varchar(20) DEFAULT NULL,
	data9 varchar(50) DEFAULT NULL,
	data9_lkup varchar(20) DEFAULT NULL,
	data10 varchar(50) DEFAULT NULL,
	data10_lkup varchar(20) DEFAULT NULL,
	data11 varchar(50) DEFAULT NULL,
	data11_lkup varchar(20) DEFAULT NULL,
	data12 varchar(50) DEFAULT NULL,
	data12_lkup varchar(20) DEFAULT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.lookup
(
	lookup_id serial,
	lookup_type_id smallint NOT NULL,
	code smallint NOT NULL,
	text varchar(100) DEFAULT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.lookuptype
(
	lookup_type_id smallint NOT NULL,
	name varchar(3) DEFAULT NULL,
	description varchar(3) DEFAULT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.medical
(
	medcode bigint NOT NULL,
	readcode varchar(7) DEFAULT NULL,
	clinicalevents bigint DEFAULT NULL,	
	immunisationevents bigint DEFAULT NULL,
	referralevents bigint DEFAULT NULL,
	testevents bigint DEFAULT NULL,
	"desc" varchar(100) DEFAULT NULL,
	databaserelease varchar(15) DEFAULT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.packtype
(
	packtype int NOT NULL,
	packtype_desc varchar(21) DEFAULT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.product
(
	prodcode bigint NOT NULL,
	dmdcode varchar(20) DEFAULT NULL,
	gemscriptcode varchar(8) DEFAULT NULL,
	therapyevents bigint DEFAULT NULL,
	productname varchar(500) DEFAULT NULL,
	drugsubstance varchar(1500) DEFAULT NULL,
	strength varchar(1100) DEFAULT NULL,
	formulation varchar(100) DEFAULT NULL,
	route varchar(110) DEFAULT NULL,
	bnfcode varchar(100) DEFAULT NULL,
	bnfchapter varchar(500) DEFAULT NULL,
	databaserelease varchar(15) DEFAULT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.scoremethod
(
	code integer NOT NULL,
	scoringmethod varchar(20) DEFAULT NULL
)TABLESPACE pg_default;
