--------------Creating  Patient Table ---------------------------------------
------------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesop_patient(
	patid			bigint,
	pracid			int,
	gen_hesid		bigint,
	n_patid_hes		int,
	gen_ethnicity	varchar(10),
	match_rank		int)
	TABLESPACE pg_default;

------------------------------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesop_patient_pathway(
	patid			bigint,
	attendkey		bigint,
	perend			date,
	perstart		date,
	subdate			date,
	HES_yr			int)
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
	waiting			int,
	HES_yr			int)
	TABLESPACE pg_default;
	
------------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesop_clinical(
	patid			bigint,
	attendkey		bigint,
	diag_01			varchar(8),
	diag_02			varchar(8),
	diag_03			varchar(8),
	diag_04			varchar(8),
	diag_05			varchar(8),
	diag_06			varchar(8),
	diag_07			varchar(8),
	diag_08			varchar(8),
	diag_09			varchar(8),
	diag_10			varchar(8),
	diag_11			varchar(8),
	diag_12			varchar(8),
	opertn_01		varchar(8),
	opertn_02		varchar(8),
	opertn_03		varchar(8),
	opertn_04		varchar(8),
	opertn_05		varchar(8),
	opertn_06		varchar(8),
	opertn_07		varchar(8),
	opertn_08		varchar(8),
	opertn_09		varchar(8),
	opertn_10		varchar(8),
	opertn_11		varchar(8),
	opertn_12		varchar(8),
	opertn_13		varchar(8),
	opertn_14		varchar(8),
	opertn_15		varchar(8),
	opertn_16		varchar(8),
	opertn_17		varchar(8),
	opertn_18		varchar(8),
	opertn_19		varchar(8),
	opertn_20		varchar(8),
	opertn_21		varchar(8),
	opertn_22		varchar(8),
	opertn_23		varchar(8),
	opertn_24		varchar(8),
	operstat		varchar(8),
	tretspef		varchar(3),
	mainspef		varchar(3),
	HES_yr			int)
	TABLESPACE pg_default;