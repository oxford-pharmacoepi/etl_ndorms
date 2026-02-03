CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.lookup626
(
	code smallint NOT NULL,
	description varchar(20) NOT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.gold_product
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


CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.gold_daysupply_decodes
(
    id integer NOT NULL,
    prodcode integer NOT NULL,
    daily_dose numeric(15,3) NOT NULL,
    qty numeric(9,2) NOT NULL,
    numpacks integer NOT NULL,
    numdays smallint NOT NULL
	
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.gold_daysupply_modes
(
    id integer,
    prodcode integer NOT NULL,
    numdays smallint NOT NULL
)TABLESPACE pg_default;