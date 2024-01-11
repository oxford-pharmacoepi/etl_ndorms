---------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesae_patient (
    patid			bigint,
    pracid			int,
    gen_hesid		bigint,
    n_patid_hes		int,
    gen_ethnicity	varchar(10),
    match_rank		int
);
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
    initdur			int,
    tretdur			int,
    concldur		int,
    depdur			int,
    ethnos			varchar(10)
);
---------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesae_diagnosis (
    patid			bigint,
    aekey			bigint,
    diag			varchar(6),
    diag2			varchar(2),
    diag3			varchar(3),
    diaga			varchar(2),
    diags			varchar(1),
    diag_order		int,
	diagscheme		int
);
---------------------------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesae_investigation (
    patid			bigint,
    aekey			bigint,
    invest			varchar(6),
    invest2			varchar(2),
    invest_order	int
);
---------------------------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesae_treatment (
    patid			bigint,
    aekey			bigint,
    treat			varchar(6),
    treat2			varchar(2),
    treat3			varchar(3),
    treat_order		int
);
----------------------------------------------------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesae_hrg (
    patid			bigint,
    aekey			bigint,
    domproc			varchar(6),
    hrgnhs			varchar(3),
    hrgnhsvn		varchar(3),
    sushrg			varchar(6),
    sushrgvers		numeric
);
--------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.hesae_pathway (
    patid			bigint,
    aekey			bigint,
    rttperstart		date,
    rttperend		date
);
