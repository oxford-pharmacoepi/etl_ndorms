CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.patient (
	patid bigint NOT NULL,
	vmid bigint DEFAULT NULL,
	gender smallint DEFAULT NULL,
	yob smallint DEFAULT NULL,
	mob smallint DEFAULT NULL,
	marital smallint DEFAULT NULL,
	famnum	bigint DEFAULT NULL,
	chsreg smallint DEFAULT NULL,
	chsdate date DEFAULT NULL,
	prescr smallint DEFAULT NULL,
	capsup smallint DEFAULT NULL,
	frd date DEFAULT NULL,
	crd date DEFAULT NULL,
	regstat int DEFAULT NULL,
	reggap int DEFAULT NULL,
	internal smallint DEFAULT NULL,
	tod date DEFAULT NULL,
	toreason smallint DEFAULT NULL,
	deathdate date DEFAULT NULL,
	accept smallint NOT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.practice (
	pracid int NOT NULL,
	region smallint DEFAULT NULL,
	lcd date DEFAULT NULL,
	uts date DEFAULT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.staff (
	staffid bigint NOT NULL,
	gender smallint DEFAULT NULL,
	role smallint DEFAULT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.consultation (
--	id serial,
	patid bigint DEFAULT NULL,
	eventdate date DEFAULT NULL,
	"sysdate" date DEFAULT NULL,
	constype smallint DEFAULT NULL,
	consid bigint DEFAULT NULL,
	staffid bigint DEFAULT NULL,
	duration int DEFAULT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.clinical (
--	id serial,
	patid bigint DEFAULT NULL,
	eventdate date DEFAULT NULL,
	"sysdate" date DEFAULT NULL,
	constype smallint DEFAULT NULL,
	consid bigint DEFAULT NULL,
	medcode bigint DEFAULT NULL,
	sctid varchar(20) DEFAULT NULL,
	sctdescid varchar(20) DEFAULT NULL,
	sctexpression varchar(20) DEFAULT NULL,
	sctmaptype smallint DEFAULT NULL,
	sctmapversion integer DEFAULT NULL,
	sctisindicative varchar(1) DEFAULT NULL,
	sctisassured varchar(1) DEFAULT NULL,
	staffid bigint DEFAULT NULL,
	episode smallint DEFAULT NULL,
	enttype smallint DEFAULT NULL,
	adid bigint DEFAULT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.additional (
--	id serial,
	patid bigint DEFAULT NULL,
	enttype integer DEFAULT NULL,
	adid bigint DEFAULT NULL,
	data1  VARCHAR(20) DEFAULT NULL,
	data2  VARCHAR(20) DEFAULT NULL,
	data3  VARCHAR(20) DEFAULT NULL,
	data4  VARCHAR(20) DEFAULT NULL,
	data5  VARCHAR(20) DEFAULT NULL,
	data6  VARCHAR(20) DEFAULT NULL,
	data7  VARCHAR(20) DEFAULT NULL,
	data8  VARCHAR(20) DEFAULT NULL,
	data9  VARCHAR(20) DEFAULT NULL,
	data10 VARCHAR(20) DEFAULT NULL,
	data11 VARCHAR(20) DEFAULT NULL,
	data12 VARCHAR(20) DEFAULT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.referral (
--	id serial,
	patid bigint DEFAULT NULL,
	eventdate date DEFAULT NULL,
	"sysdate" date DEFAULT NULL,
	constype smallint DEFAULT NULL,
	consid bigint DEFAULT NULL,
	medcode bigint DEFAULT NULL,
	sctid varchar(20) DEFAULT NULL,
	sctdescid varchar(20) DEFAULT NULL,
	sctexpression varchar(20) DEFAULT NULL,
	sctmaptype smallint DEFAULT NULL,
	sctmapversion integer DEFAULT NULL,
	sctisindicative varchar(1) DEFAULT NULL,
	sctisassured varchar(1) DEFAULT NULL,
	staffid bigint DEFAULT NULL,
	source smallint DEFAULT NULL,
	nhsspec smallint DEFAULT NULL,
	fhsaspec smallint DEFAULT NULL,
	inpatient smallint DEFAULT NULL,
	attendance smallint DEFAULT NULL,
	urgency smallint DEFAULT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.immunisation (
--	id serial,
	patid bigint DEFAULT NULL,
	eventdate date DEFAULT NULL,
	"sysdate" date DEFAULT NULL,
	constype smallint DEFAULT NULL,
	consid bigint DEFAULT NULL,
	medcode bigint DEFAULT NULL,
	sctid varchar(20) DEFAULT NULL,
	sctdescid varchar(20) DEFAULT NULL,
	sctexpression varchar(20) DEFAULT NULL,
	sctmaptype smallint DEFAULT NULL,
	sctmapversion integer DEFAULT NULL,
	sctisindicative varchar(1) DEFAULT NULL,
	sctisassured varchar(1) DEFAULT NULL,
	staffid bigint DEFAULT NULL,
	immstype smallint DEFAULT NULL,
	stage smallint DEFAULT NULL,
	status smallint DEFAULT NULL,
	compound smallint DEFAULT NULL,
	source smallint DEFAULT NULL,
	reason smallint DEFAULT NULL,
	method smallint DEFAULT NULL,
	batch bigint DEFAULT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.test (
--	id serial,
	patid bigint DEFAULT NULL,
	eventdate date DEFAULT NULL,
	"sysdate" date DEFAULT NULL,
	constype smallint DEFAULT NULL,
	consid integer DEFAULT NULL,
	medcode bigint DEFAULT NULL,
	sctid varchar(20) DEFAULT NULL,
	sctdescid varchar(20) DEFAULT NULL,
	sctexpression varchar(20) DEFAULT NULL,
	sctmaptype smallint DEFAULT NULL,
	sctmapversion integer DEFAULT NULL,
	sctisindicative varchar(1) DEFAULT NULL,
	sctisassured varchar(1) DEFAULT NULL,
	staffid bigint DEFAULT NULL,
	enttype integer DEFAULT NULL,
	data1 VARCHAR(20) DEFAULT NULL,
	data2 VARCHAR(20) DEFAULT NULL,
	data3 VARCHAR(20) DEFAULT NULL,
	data4 VARCHAR(20) DEFAULT NULL,
	data5 VARCHAR(20) DEFAULT NULL,
	data6 VARCHAR(20) DEFAULT NULL,
	data7 VARCHAR(20) DEFAULT NULL,
	data8 VARCHAR(20) DEFAULT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.therapy (
--	id serial,
	patid bigint DEFAULT NULL,
	eventdate date DEFAULT NULL,
	"sysdate" date DEFAULT NULL,
	consid bigint DEFAULT NULL,
	prodcode bigint DEFAULT NULL,
	drugdmd varchar(20) DEFAULT NULL,
	staffid bigint DEFAULT NULL,
	dosageid varchar(64) DEFAULT NULL,
	bnfcode smallint DEFAULT NULL,
	qty numeric(11,3) DEFAULT NULL,
	numdays integer DEFAULT NULL,
	numpacks numeric(10,3) DEFAULT NULL,
	packtype integer DEFAULT NULL,
	issueseq integer DEFAULT NULL,
	prn smallint DEFAULT NULL
)TABLESPACE pg_default;


