CREATE SCHEMA IF NOT EXISTS {LINKAGE_SCHEMA};

CREATE TABLE IF NOT EXISTS {LINKAGE_SCHEMA}.linkage_coverage
(
	data_source varchar(10) NOT NULL,
	"start" DATE NOT NULL,
	"end" DATE NOT NULL
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {LINKAGE_SCHEMA}.linkage_eligibility (
	patid bigint,
	pracid integer,
	linkyear integer,
	hes_ae_e smallint,
	hes_apc_e smallint,
	hes_op_e smallint,
	ons_death_e smallint,
	lsoa_e smallint,
	bsa_dispensing_e smallint,
	sgss_e smallint,
	chess_e smallint,
	hes_did_e smallint,
	cr_e smallint,
	sact_e smallint,
	rtds_e smallint
) TABLESPACE pg_default;