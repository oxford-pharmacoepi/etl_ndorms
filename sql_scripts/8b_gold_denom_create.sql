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

