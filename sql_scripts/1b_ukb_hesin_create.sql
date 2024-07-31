CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.baseline (
	eid				bigint 		not null,	
	p31				smallint,
	p34				smallint,
	p52				smallint,
	p53_i0			date,
	p53_i1			date,
	p53_i2			date,
	p53_i3			date,
	p54_i0			NUMERIC,
	p54_i1			NUMERIC,
	p54_i2			NUMERIC,
	p54_i3			NUMERIC,
	p200			date,
	p20143			date,
	p21000_i0		NUMERIC,
	p21000_i1		NUMERIC,
	p21000_i2		NUMERIC,
	p21000_i3		NUMERIC,
	p21022			int,
	p22189			NUMERIC,
	p26410			NUMERIC,
	p26426			NUMERIC,
	p26427			NUMERIC
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.death (
	eid					bigint,	
	ins_index			int,
	dsource				VARCHAR(4),
	source				int,
	date_of_death		date
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.death_cause (
	eid					bigint,	
	ins_index			int,
	arr_index			int,
	level				int,
	cause_icd10			VARCHAR(8)
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesin (
	eid						bigint,
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
	admimeth_uni			int,
	admimeth				varchar(4),
	admisorc_uni			int,
	admisorc				varchar(4),
	firstreg				int,
	classpat_uni			int,
	classpat				varchar(4),
	intmanag_uni			int,
	intmanag				int,
	mainspef_uni			int,
	mainspef				varchar(10),
	tretspef_uni			int,
	tretspef				varchar(10),
	operstat				int,
	disdate					date,
	dismeth_uni				int,
	dismeth					int,
	disdest_uni				int,
	disdest					varchar(2),
	carersi					int
)TABLESPACE pg_default;
	
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesin_critical (
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
	ccdisrdydate		date,
	ccdisstat			int,
	ccdisdest			int,
	ccdisloc			int,
	ccapcrel			int,
	bressupdays			int,
	aressupdays			int,
	bcardsupdays		int,
	acardsupdays		int,
	rensupdays			int,
	neurosupdays		int,
	gisupdays			int,
	dermsupdays			int,
	liversupdays		int,
	orgsupmax			int,
	cclev2days			int,
	cclev3days			int,
	ccunitfun			int,
	unitbedconfig		int
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesin_delivery (
	eid					bigint,
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
	delstat				int
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesin_diag (
	eid					bigint,
	ins_index			bigint,
	arr_index			bigint,
	level				int,
	diag_icd9			varchar(10),
	diag_icd9_nb		varchar(10),
	diag_icd10			varchar(10),
	diag_icd10_nb		varchar(10)
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesin_maternity (
	eid					bigint,
	ins_index			bigint,
	numbaby				varchar(1),
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
	matage				int
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesin_oper (
	eid					bigint,
	ins_index			bigint,
	arr_index			bigint,
	level				int,
	opdate				date,
	oper3				varchar(10),
	oper3_nb			varchar(10),
	oper4				varchar(10),
	oper4_nb			varchar(10),
	posopdur			int,
	preopdur			int
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesin_psych (
	eid					bigint,
	ins_index			bigint,
	detncat_uni			int,
	detncat				int,
	detndate			date,
	mentcat				int,
	admistat_uni		int,
	admistat			int,
	leglstat			int
)TABLESPACE pg_default;