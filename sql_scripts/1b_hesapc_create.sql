--------------Creating  Patient Table ---------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hes_patient (
	patid 			bigint,
	pracid 			int,
	mpsid			bigint,
	gen_ethnicity 	varchar(10))
	TABLESPACE pg_default;
	
---------------Creating Hospitalisations Table---------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hes_hospital (
	patid		bigint,
	spno		int,
	admidate	date,
	discharged	date,
	admimeth	varchar(5),
	admisorc	int,
	disdest		int,
	dismeth		int,
	duration	int,
	elecdate	date,
	elecdur		int)
	TABLESPACE pg_default;
	
------------- Creating Episodes Table---------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hes_episodes (
	patid		bigint,
	spno		int,
	epikey		bigint,
	admidate	date,
	epistart	date,
	epiend		date,
	discharged	date,
	eorder		int,
	epidur		int,
	epitype		int,
	admimeth	varchar(2),
	admisorc	int,
	disdest		int,
	dismeth		int,
	mainspef	varchar(3),
	tretspef	varchar(3),
	pconsult	varchar(16),
	intmanig	int,
	classpat	int,
	firstreg	varchar(2),
	ethnos		varchar(10))
	TABLESPACE pg_default;
	
------------Creating  Diagnoses Tables-----------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hes_diagnosis_epi (
	patid		bigint,
	spno		int,
	epikey		bigint,
	epistart	date,
	epiend		date,
	icd			varchar(5),
	icdx		varchar(5),
	d_order		smallint)
	TABLESPACE pg_default;


CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hes_diagnosis_hosp (
	patid		bigint,
	spno		int,
	admidate	date,
	discharged	date,
	icd			varchar(5),
	icdx		varchar(5))
	TABLESPACE pg_default;

------Creating Hes_Primary_diag_hosp Table------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hes_primary_diag_hosp (
	patid		bigint,
	spno		int,
	admidate	date,
	discharged	date,
	icd_primary	varchar(5),
	icdx		varchar(5))
	TABLESPACE pg_default;

	
----------- Creating Procedures Table --------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hes_procedures_epi (
	patid		bigint,
	spno		int,
	epikey  	bigint,
	admidate	date,
	epistart	date,
	epiend 		date,
	discharged	date,
	OPCS		varchar(5),
	evdate 		date,
	p_order 	int)
	TABLESPACE pg_default;
	
----------- FILE WAS REMOVED --Creating  Augmented Care Periods – ACP Table ------------------------
--CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hes_acp ( --
--	patid		bigint,
--	spno		int,
--	epikey 		bigint,
--	epistart 	date,
--	epiend 		date,
--	eorder 		int,
--	epidur 		int,
--	numacp 		int,
--	acpn 		int,
--	acpstar 	date,
--	acpend 		date,
--	acpdur 		int,
--	intdays 	int,
--	depdays 	int,
--	acploc 		int,
--	acpsour 	int,
--	acpdisp 	int,
--	acpout 		int,
--	acpplan 	char(1),
--	acpspef 	varchar(3),
--	orgsup 		int,
--	acpdqind 	char(1))
--	TABLESPACE pg_default;
	
-------------Creating Critical Care Table----------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hes_ccare (
	patid			bigint,
	spno			int,
	epikey 			bigint,
	admidate 		date,
	discharged 		date,
	epistart 		date,
	epiend 			date,
	eorder 			int,
	ccstartdate 	date,
	ccstarttime 	varchar(8),
	ccdisrdydate 	date,
	ccdisrdytime 	varchar(8),
	ccdisdate 		date,
	ccdistime 		varchar(8),
	ccadmitype 		varchar(9),
	ccadmisorc 		int,
	ccsorcloc 		int,
	ccdisstat 		int,
	ccdisdest 		int,
	ccdisloc 		int,
	cclev2days 		int,
	cclev3days 		int,
	bcardsupdays 	int,
	acardsupdays 	int,
	bressupdays 	int,
	aressupdays 	int,
	gisupdays 		int,
	liversupdays 	int,
	neurosupdays 	int,
	rensupdays 		int,
	dermsupdays 	int,
	orgsupmax 		int,
	ccunitfun 		int,
	unitbedconfig 	int,
	bestmatch 		int,
	ccapcrel 		int)
	TABLESPACE pg_default;
	
------Creating Maternity Table ---------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hes_maternity (
	patid			bigint,
	spno			int,
	epikey  		bigint,
	epistart 		date,
	epiend 			date,
	eorder 			int,
	epidur 			int,
	numbaby 		char(1),
	numtailb 		int,
	matordr 		int,
	neocare 		int,
	wellbaby 		char(1),
	anasdate 		date,
	birordr 		char(1),
	birstat 		int,
	biresus 		int,
	sexbaby 		char(1),
	birweit 		int,
	delmeth 		char(1),
	delonset 		int,
	delinten 		int,
	delplac 		int,
	delchang 		int,
	delprean 		int,
	delposan 		int,
	delstat 		int,
	anagest 		int,
	gestat 			int,
	numpreg 		int,
	matage 			int,
	neodur 			int,
	antedur 		int,
	postdur 		int)
	TABLESPACE pg_default;

------Creating source_hesapc.hes_hrg Table------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hes_hrg (
	patid		bigint,
	spno		int,
	epikey 		bigint,
	domproc 	varchar(5),
	hrglate35 	varchar(4),
	hrgnhs 		varchar(4),
	hrgnhsvn 	varchar(3),
	suscorehrg 	varchar(5),
	sushrg 		varchar(5),
	sushrgvers 	NUMERIC(2,1),
	hes_yr 		smallint)
	TABLESPACE pg_default;
	
