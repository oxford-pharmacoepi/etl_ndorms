---Creating biob_hesin Table ---------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.biob_hesin (
	eid					bigint,
	ins_index				bigint,
	dsource					varchar(10),
	source					int,
	epistart				date,
	epiend					date,
	epidur					int,
	bedyear					int,
	epistat					int,
	epitype					int,
	epiorder				int,
	spell_index				int,
	spell_seq				int,
	spelbgin				int,
	spelend					varchar(10),
	speldur					int,
	pctcode					varchar(10),
	gpprpct					varchar(10),
	category				int,
	elecdate				date,
	elecdur					int,
	admidate				date,
	admimeth_uni				int,
	admimeth				int,
	admisorc_uni				int,
	admisorc				int,
	firstreg				int,
	classpat_uni				int,
	classpat				int,
	intmanag_uni				int,
	intmanag				int,
	mainspef_uni				int,
	mainspef				varchar(10),
	tretspef_uni				int,
	tretspef				varchar(10),
	operstat				int,
	disdate					date,
	dismeth_uni				int,
	dismeth					int,
	disdest_uni				int,
	disdest					int,
	carersi					int)
	TABLESPACE pg_default;
	
---Creating biob_hesin_critical Table ---------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.biob_hesin_critical (
	eid				bigint,
	ins_index			bigint,
	arr_index			bigint,
	dsource				varchar(10),
	source				int,
	ccstartdate			date,
	ccadmitype			int,
	ccadmisorc			int,
	ccsorcloc			int,
	ccdisdate			date,
	ccdisrdydate			date,
	ccdisstat			int,
	ccdisdest			int,
	ccdisloc			int,
	ccapcrel			int,
	bressupdays			int,
	aressupdays			int,
	bcardsupdays			int,
	acardsupdays			int,
	rensupdays			int,
	neurosupdays			int,
	gisupdays			int,
	dermsupdays			int,
	liversupdays			int,
	orgsupmax			int,
	cclev2days			int,
	cclev3days			int,
	ccunitfun			int,
	unitbedconfig			int)
	TABLESPACE pg_default;

---Creating biob_hesin_delivery Table ---------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.biob_hesin_delivery (
	eid				bigint,
	ins_index			bigint,
	arr_index			bigint,
	gestat				int,
	delplac				int,
	delmeth				varchar(10),
	birordr				varchar(10),
	birstat				int,
	biresus				int,
	sexbaby				int,
	birweight			int,
	delstat				int)
	TABLESPACE pg_default;

---Creating biob_hesin_diag Table ---------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.biob_hesin_diag (
	eid				bigint,
	ins_index			bigint,
	arr_index			bigint,
	level				int,
	diag_icd9			varchar(10),
	diag_icd9_nb			varchar(10),
	diag_icd10			varchar(10),
	diag_icd10_nb			varchar(10))
	TABLESPACE pg_default;

---Creating biob_hesin_maternity Table ---------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.biob_hesin_maternity (
	eid				bigint,
	ins_index			bigint,
	numbaby				int,
	numpreg				int,
	anasdate			date,
	anagest				int,
	antedur				int,
	delinten			int,
	delchang			int,
	delprean			int,
	delposan			int,
	delonset			int,
	postdur				int,
	matage				int)
	TABLESPACE pg_default;

---Creating biob_hesin_oper Table ---------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.biob_hesin_oper (
	eid				bigint,
	ins_index			bigint,
	arr_index			bigint,
	level				int,
	opdate				date,
	oper3				varchar(10),
	oper3_nb			varchar(10),
	oper4				varchar(10),
	oper4_nb			varchar(10),
	posopdur			int,
	preopdur			int)
	TABLESPACE pg_default;

---Creating biob_hesin_psych Table ---------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.biob_hesin_psych (
	eid				bigint,
	ins_index			bigint,
	detncat_uni			int,
	detncat				int,
	detndate			date,
	mentcat				int,
	admistat_uni			int,
	admistat			int,
	leglstat			int)
	TABLESPACE pg_default;