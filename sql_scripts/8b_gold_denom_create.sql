CREATE SCHEMA IF NOT EXISTS {SOURCE_SCHEMA};
CREATE SCHEMA IF NOT EXISTS {SOURCE_NOK_SCHEMA};
CREATE SCHEMA IF NOT EXISTS temp;
CREATE SCHEMA IF NOT EXISTS results;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.gold_acceptable_pats (
	patid bigint,
	gender char(1),
	yob int,
	mob int,
	frd date,
	crd date,
	regstat int DEFAULT NULL,
	reggap int DEFAULT NULL,
	internal smallint DEFAULT NULL,
	tod date DEFAULT NULL,
	toreason smallint DEFAULT NULL,
	deathdate date
) TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.gold_allpractices (
	pracid int,
	region int,
	lcd date,
	uts date
) TABLESPACE pg_default;

patid	pracid	linkdate	hes_apc_e	ons_death_e	lsoa_e	sgss_e	chess_e	hes_op_e	hes_ae_e	hes_did_e	cr_e	sact_e	rtds_e	mhds_e	icnarc_e

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.gold_eligibility (
	patid bigint,
	pracid integer,
	linkdare date,
	hes_apc_e smallint,
	ons_death_e smallint,
	lsoa_e smallint,
	sgss_e smallint,
	chess_e smallint,
	hes_op_e smallint,
	hes_ae_e smallint,
	hes_did_e smallint,
	cr_e smallint,
	sact_e smallint,
	rtds_e smallint,
	mhds_e smallint,
	icnarc_e smallint
) TABLESPACE pg_default;
