---------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesae_patient (
    patid			bigint,
    pracid			int,
    gen_hesid		bigint,
    n_patid_hes		smallint,
    gen_ethnicity	varchar(10),
    match_rank		smallint)
TABLESPACE pg_default;
	
-----------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesae_attendance (
    patid			bigint,
    aekey			bigint,
    arrivaldate		date,
    aepatgroup		int,
    aeattendcat		int,
    aearrivalmode	int,
    aedepttype		int,
    aerefsource		int,
    aeincloctype	int,
    aeattenddisp	int,
    initdur			smallint,
    tretdur			smallint,
    concldur		smallint,
    depdur			smallint,
    ethnos			varchar(10))
TABLESPACE pg_default;
	
---------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesae_diagnosis (
    patid			bigint,
    aekey			bigint,
    diag			varchar(6),
    diag2			varchar(2),
    diag3			varchar(3),
    diaga			varchar(2),
    diags			varchar(1),
    diag_order		smallint,
	diagscheme		smallint)
TABLESPACE pg_default;
	
---------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesae_investigation (
    patid			bigint,
    aekey			bigint,
    invest			varchar(6),
    invest2			varchar(2),
    invest_order	smallint)
TABLESPACE pg_default;
	
---------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesae_treatment (
    patid			bigint,
    aekey			bigint,
    treat			varchar(6),
    treat2			varchar(2),
    treat3			varchar(3),
    treat_order		smallint)
TABLESPACE pg_default;
	
----------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesae_hrg (
    patid			bigint,
    aekey			bigint,
    domproc			varchar(6),
    hrgnhs			varchar(3),
    hrgnhsvn		varchar(3),
    sushrg			varchar(6),
    sushrgvers		numeric)
TABLESPACE pg_default;
	
--------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesae_pathway (
    patid			bigint,
    aekey			bigint,
    rttperstart		date,
    rttperend		date)
TABLESPACE pg_default;