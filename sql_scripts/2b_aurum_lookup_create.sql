CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.gender
(
	genderid integer NOT NULL,
	description character(1) NOT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.jobcat
(
	jobcatid integer NOT NULL,
	description varchar(100) NOT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.numunit
(
	numunitid integer NOT NULL,
	description varchar(100) NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.quantunit
(
	quantunitid integer NOT NULL,
	description varchar(50) NOT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.refservicetype
(
	refservicetypeid integer NOT NULL,
	description varchar(50) NOT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.region
(
	regionid integer NOT NULL,
	description varchar(30) NOT NULL
)TABLESPACE pg_default;

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
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.productdictionary
(
	prodcodeid bigint NOT NULL,
	dmdid varchar(20),
	termfromemis varchar(250),
	productname varchar(250),
	formulation varchar(250),
	routeofadministration varchar(120),
	drugsubstancename varchar(1000),
	substancestrength varchar(650),
	bnfchapter varchar(200),
	drugissues bigint NOT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.VisionToEmisMigrators
(
	gold_pracid		integer NOT NULL,
	gold_lcdate		date NOT NULL,
	emis_pracid		integer NOT NULL,
	emis_joindate	date NOT NULL,
	emis_fdcdate	date NOT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.common_dosages
(
	dosageid			varchar(64) NOT NULL,
	dosage_text			varchar(1000),
	daily_dose			real,
	dose_number			real,
	dose_unit			varchar(7),
	dose_frequency		real,
	dose_interval		real,
	choice_of_dose		int,
	dose_max_average 	int,
	change_dose			int,
	dose_duration		real
)TABLESPACE pg_default;


CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.PatientType
(
	patienttypeid int NOT NULL,
	description varchar(50)
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.ConsSource
(
	id bigint NOT NULL,
	description varchar(255)
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.RefUrgency
(
	refurgencyid int NOT NULL,
	description varchar(255)
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.RefMode
(
	refmodeid int NOT NULL,
	description varchar(255)
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.ParentProbRel
(
	parentprobrelid int NOT NULL,
	description varchar(255)
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.ProbStatus
(
	probstatusid int NOT NULL,
	description varchar(255)
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.Sign
(
	signid int NOT NULL,
	description varchar(255)
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.emiscodecat
(
	emiscodecatid int NOT NULL,
	description varchar(255)
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.obstype
(
	obstypeid int NOT NULL,
	description varchar(255)
)TABLESPACE pg_default;



