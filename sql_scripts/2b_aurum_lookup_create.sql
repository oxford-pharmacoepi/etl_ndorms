CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.gender
(
	genderid integer NOT NULL,
	description character(1) NOT NULL
);

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.jobcat
(
	jobcatid integer NOT NULL,
	description varchar(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.numunit
(
	numunitid integer NOT NULL,
	description varchar(100) NULL
);

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.quantunit
(
	quantunitid integer NOT NULL,
	description varchar(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.refservicetype
(
	refservicetypeid integer NOT NULL,
	description varchar(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.region
(
	regionid integer NOT NULL,
	description varchar(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.medicaldictionary
(
	medcodeid bigint NOT NULL,
	observations bigint,
	originalreadcode varchar(25),
	cleansedreadcode varchar(10),
	term varchar(265),
	snomedctconceptid varchar(20),
	snomedctdescriptionid varchar(20),
	release varchar(1),
	emiscodecategoryid smallint
);

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.productdictionary
(
	prodcodeid bigint NOT NULL,
	dmdid varchar(20),
	termfromemis varchar(250),
	productname varchar(250),
	formulation varchar(250),
	routeofadministration varchar(100),
	drugsubstancename varchar(1000),
	substancestrength varchar(650),
	bnfchapter varchar(200),
	drugissues bigint NOT NULL
);

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.VisionToEmisMigrators
(
	gold_pracid		integer NOT NULL,
	gold_lcdate		date NOT NULL,
	emis_pracid		integer NOT NULL,
	emis_joindate	date NOT NULL,
	emis_fdcdate	date NOT NULL
);
