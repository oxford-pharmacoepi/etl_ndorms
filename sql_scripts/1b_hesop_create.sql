--------------Creating  Patient Table ---------------------------------------
------------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesop_patient(
	patid			bigint,
	pracid			int,
	cprd_mpsid		bigint,
	gen_ethnicity	varchar(10)
)
TABLESPACE pg_default;

------------------------------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesop_patient_pathway(
	patid			bigint,
	attendkey		bigint,
	subdate			date
)
TABLESPACE pg_default;
	
------------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesop_appointment(
	patid			bigint,
	attendkey		bigint,
	ethnos			varchar(11),
	admincat		int,
	apptdate		date,
	apptage			int,
	atentype		int,
	attended		int,
	dnadate			date,
	firstatt		varchar(1),
	outcome			int,
	priority		int,
	refsourc		int,
	reqdate			date,
	servtype		int,
	stafftyp		int,
	wait_ind		int,
	waiting			int
)
TABLESPACE pg_default;
	
------------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesop_clinical(
	patid			bigint,
	attendkey		bigint,
	diagnosis		varchar(9),
	icdx			varchar(9),
	icd				varchar(9),
	diag_order		smallint,
	tretspef		varchar(9),
	mainspef		varchar(9)
)
TABLESPACE pg_default;
------------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesop_operation(
	patid			bigint,
	attendkey		bigint,
	operation		varchar(9),
	opcs			varchar(9),
	opertn_order	smallint,
	operstat		varchar(9),
	tretspef		varchar(9),
	mainspef		varchar(9)
)
TABLESPACE pg_default;
	
