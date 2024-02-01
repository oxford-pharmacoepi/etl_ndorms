CREATE SCHEMA IF NOT EXISTS {SOURCE_NOK_SCHEMA};

DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.test CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.therapy CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.immunisation CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.additional CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.clinical CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.referral CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.consultation CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.patient CASCADE;

-- PATIENT - Remove unacceptable
CREATE TABLE {SOURCE_NOK_SCHEMA}.patient (LIKE {SOURCE_SCHEMA}.patient);

with cte1 as (
	SELECT t1.patid 
	FROM {SOURCE_SCHEMA}.patient as t1
	inner join {SOURCE_SCHEMA}.practice as t2 on MOD(t1.patid, 100000) = t2.pracid
	WHERE t1.accept = 0
	OR t1.gender in (0,3,4)
	OR t1.gender is null 
	OR t1.yob < 75
	OR (t1.yob + 1800) > date_part('year', CURRENT_DATE)
	OR t1.frd is null
	OR LEAST(t1.tod, t2.lcd, t1.deathdate, to_date(CONCAT(RIGHT(current_database(), 6), '01'), 'YYYYMMDD')) < GREATEST(t1.frd, t2.uts)
)
INSERT INTO {SOURCE_NOK_SCHEMA}.patient
SELECT t1.* 
FROM {SOURCE_SCHEMA}.patient as t1
INNER JOIN cte1 on cte1.patid = t1.patid;

alter table {SOURCE_NOK_SCHEMA}.patient add constraint pk_patient_nok primary key (patid);

DELETE FROM {SOURCE_SCHEMA}.patient as t1 
using {SOURCE_NOK_SCHEMA}.patient as t2
WHERE t1.patid = t2.patid;


-- CONSULTATION - Remove records with NULL EVENTDATE
CREATE TABLE {SOURCE_NOK_SCHEMA}.consultation (LIKE {SOURCE_SCHEMA}.consultation);

with cte2 as (
	SELECT *
	FROM {SOURCE_SCHEMA}.consultation
	WHERE eventdate is null
)
INSERT INTO {SOURCE_NOK_SCHEMA}.consultation
SELECT * 
FROM cte2;

DELETE FROM {SOURCE_SCHEMA}.consultation
WHERE eventdate is null;

-- CLINICAL - Remove records with NULL EVENTDATE
CREATE TABLE {SOURCE_NOK_SCHEMA}.clinical (LIKE {SOURCE_SCHEMA}.clinical);

with cte3 as (
	SELECT *
	FROM {SOURCE_SCHEMA}.clinical
	WHERE eventdate is null
)
INSERT INTO {SOURCE_NOK_SCHEMA}.clinical
SELECT * 
FROM cte3;

DELETE FROM {SOURCE_SCHEMA}.clinical
WHERE eventdate is null;


-- REFERRAL - Remove records with NULL EVENTDATE
CREATE TABLE {SOURCE_NOK_SCHEMA}.referral (LIKE {SOURCE_SCHEMA}.referral);

with cte4 as (
	SELECT *
	FROM {SOURCE_SCHEMA}.referral
	WHERE eventdate is null
)
INSERT INTO {SOURCE_NOK_SCHEMA}.referral
SELECT * 
FROM cte4;

DELETE FROM {SOURCE_SCHEMA}.referral
WHERE eventdate is null;


-- THERAPY - Remove records with NULL EVENTDATE
CREATE TABLE {SOURCE_NOK_SCHEMA}.therapy (LIKE {SOURCE_SCHEMA}.therapy);

with cte5 as (
	SELECT *
	FROM {SOURCE_SCHEMA}.therapy
	WHERE eventdate is null
)
INSERT INTO {SOURCE_NOK_SCHEMA}.therapy
SELECT * 
FROM cte5;

DELETE FROM {SOURCE_SCHEMA}.therapy
WHERE eventdate is null;


-- IMMUNISATION - Remove records with NULL EVENTDATE
CREATE TABLE {SOURCE_NOK_SCHEMA}.immunisation (LIKE {SOURCE_SCHEMA}.immunisation);

with cte6 as (
	SELECT *
	FROM {SOURCE_SCHEMA}.immunisation
	WHERE eventdate is null
)
INSERT INTO {SOURCE_NOK_SCHEMA}.immunisation
SELECT * 
FROM cte6;

DELETE FROM {SOURCE_SCHEMA}.immunisation
WHERE eventdate is null;


-- TEST - Remove records with NULL EVENTDATE
CREATE TABLE {SOURCE_NOK_SCHEMA}.test (LIKE {SOURCE_SCHEMA}.test);

with cte7 as (
	SELECT *
	FROM {SOURCE_SCHEMA}.test
	WHERE eventdate is null
)
INSERT INTO {SOURCE_NOK_SCHEMA}.test
SELECT * 
FROM cte7;

DELETE FROM {SOURCE_SCHEMA}.test
WHERE eventdate is null;

