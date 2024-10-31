CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.lookup626
(
	code smallint NOT NULL,
	description varchar(20) NOT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.gold_product
(
    prodcode bigint NOT NULL,
    dmdcode character varying(20),
    gemscriptcode character varying(8),
    productname character varying(500),
    drugsubstance character varying(1500),
    strength character varying(1100),
    formulation character varying(100),
    route character varying(100),
    bnfcode character varying(100),
    bnfchapter character varying(500)
	
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