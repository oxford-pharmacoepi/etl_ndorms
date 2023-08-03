CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.gender
(
	genderid integer NOT NULL,
	description character(1) NOT NULL
);

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.jobcat
(
	jobcatid integer NOT NULL,
	description character varying(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.numunit
(
	numunitid integer NOT NULL,
	description character varying(100) NULL
);

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.quantunit
(
	quantunitid integer NOT NULL,
	description character varying(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.refservicetype
(
	refservicetypeid integer NOT NULL,
	description character varying(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.region
(
	regionid integer NOT NULL,
	description character varying(30) NOT NULL
);

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.medicaldictionary
(
	medcodeid bigint NOT NULL,
	observations bigint,
	originalreadcode character varying(25),
	cleansedreadcode character varying(10),
	term character varying(265),
	snomedctconceptid character varying(20),
	snomedctdescriptionid character varying(20),
	release character varying(1),
	emiscodecategoryid smallint
);

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.productdictionary
(
	prodcodeid bigint NOT NULL,
	dmdid character varying(20),
	termfromemis character varying(250),
	productname character varying(250),
	formulation character varying(250),
	routeofadministration character varying(100),
	drugsubstancename character varying(1000),
	substancestrength character varying(650),
	bnfchapter character varying(200),
	drugissues bigint NOT NULL
);

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.VisionToEmisMigrators
(
	gold_pracid		INT NOT NULL,
	gold_lcdate		DATE NOT NULL,
	emis_pracid		INT NOT NULL,
	emis_joindate	DATE NOT NULL,
	emis_fdcdate	DATE NOT NULL
);
