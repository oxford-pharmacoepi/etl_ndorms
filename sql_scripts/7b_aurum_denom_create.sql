CREATE SCHEMA IF NOT EXISTS {SOURCE_SCHEMA};
CREATE SCHEMA IF NOT EXISTS {SOURCE_NOK_SCHEMA};
CREATE SCHEMA IF NOT EXISTS temp;
CREATE SCHEMA IF NOT EXISTS results;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.aurum_acceptablepats (
	patid bigint,
	pracid int,
	gender char(1),
	yob int,
	mob int,
	emis_ddate date,
	regstartdate date,
	patienttypeid varchar(25),
	regenddate date,
	acceptable smallint,
	cprd_ddate date,
	uts date,
	lcd date,
	region int
);

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.aurum_practices (
	pracid int,
	lcd date,
	uts date,
	region int
);
