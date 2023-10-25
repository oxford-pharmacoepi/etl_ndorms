CREATE SCHEMA IF NOT EXISTS {SOURCE_NOK_SCHEMA};

DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.drugissue CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.observation CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.problem CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.referral CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.consultation CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.patient CASCADE;

-- PATIENT - remove unacceptable
CREATE TABLE {SOURCE_NOK_SCHEMA}.patient (LIKE {SOURCE_SCHEMA}.patient);

with cte1 as (
	SELECT patid FROM {SOURCE_SCHEMA}.patient
	WHERE acceptable = 0
	OR gender in (0,3,4)
	OR gender is null 
	OR yob < 1875
	OR regstartdate is null
)
INSERT INTO {SOURCE_NOK_SCHEMA}.patient
SELECT t1.* FROM {SOURCE_SCHEMA}.patient as t1
INNER JOIN cte1 on cte1.patid = t1.patid;

alter table {SOURCE_NOK_SCHEMA}.patient add constraint pk_patient_nok primary key (patid);

DELETE FROM {SOURCE_SCHEMA}.patient as t1 
using {SOURCE_NOK_SCHEMA}.patient as t2
WHERE t1.patid = t2.patid;


-- PATIENT SET TO NULL unexistent staffids
with cte2 as (
	SELECT t1.patid
	FROM {SOURCE_SCHEMA}.patient as t1
	left join {SOURCE_SCHEMA}.staff as t2 on t1.usualgpstaffid = t2.staffid
	WHERE t2.staffid is null
)
update {SOURCE_SCHEMA}.patient as t3
set usualgpstaffid = null
from cte2 where t3.patid = cte2.patid;

-- PATIENT SET TO NULL unexistent pracids
--POC	with t as (
--POC		SELECT t1.patid
--POC		FROM {SOURCE_SCHEMA}.patient as t1
--POC		left join {SOURCE_SCHEMA}.practice as t2 on t1.pracid = t2.pracid
--POC		WHERE t2.pracid is null
--POC	)
--POC	update {SOURCE_SCHEMA}.patient as t3
--POC	set pracid = null
--POC	from t where t3.patid = t.patid;

-- CONSULTATION - MOVE UNACCEPTABLE AND UNEXISTENT PATIENTS. Unacceptable patients have already been removed from {SOURCE_SCHEMA}.patient, so we can remove both unexistent and acceptable at once.
CREATE TABLE {SOURCE_NOK_SCHEMA}.consultation (LIKE {SOURCE_SCHEMA}.consultation);

with cte3 as (
	SELECT t1.consid
	FROM {SOURCE_SCHEMA}.consultation as t1
	left join {SOURCE_SCHEMA}.patient as t2 on t1.patid = t2.patid
	WHERE t2.patid is null
)
INSERT INTO {SOURCE_NOK_SCHEMA}.consultation
SELECT t1.* FROM {SOURCE_SCHEMA}.consultation as t1
INNER JOIN cte3 on cte3.consid = t1.consid;


with cte4 as (
	SELECT t1.consid
	FROM {SOURCE_SCHEMA}.consultation as t1
	left join {SOURCE_SCHEMA}.patient as t2 on t1.patid = t2.patid
	WHERE t2.patid is null
)
DELETE FROM {SOURCE_SCHEMA}.consultation as t3
USING cte4
WHERE t3.consid = cte4.consid;

-- CONSULTATION SET TO NULL unexistent staffids

with cte5 as (
	SELECT t1.consid
	FROM {SOURCE_SCHEMA}.consultation as t1
	left join {SOURCE_SCHEMA}.staff as t2 on t1.staffid = t2.staffid
	WHERE t2.staffid is null
)
update {SOURCE_SCHEMA}.consultation as t3
set staffid = null
from cte5 where t3.consid = cte5.consid;


-- DRUGISSUE - MOVE UNACCEPTABLE AND UNEXISTENT PATIENTS. Unacceptable patients have already been removed from {SOURCE_SCHEMA}.patient, so we can remove both unexistent and acceptable at once.
CREATE TABLE {SOURCE_NOK_SCHEMA}.drugissue (LIKE {SOURCE_SCHEMA}.drugissue);

with cte6 as (
	SELECT t1.issueid
	FROM {SOURCE_SCHEMA}.drugissue as t1
	left join {SOURCE_SCHEMA}.patient as t2 on t1.patid = t2.patid
	WHERE t2.patid is null
)
INSERT INTO {SOURCE_NOK_SCHEMA}.drugissue
SELECT t1.* FROM {SOURCE_SCHEMA}.drugissue as t1
INNER JOIN cte6 on cte6.issueid = t1.issueid;

with cte7 as (
	SELECT t1.issueid
	FROM {SOURCE_SCHEMA}.drugissue as t1
	left join {SOURCE_SCHEMA}.patient as t2 on t1.patid = t2.patid
	WHERE t2.patid is null
)
DELETE FROM {SOURCE_SCHEMA}.drugissue as t3
USING cte7
WHERE t3.issueid = cte7.issueid;

-- DRUGISSUE SET TO NULL unexistent staffids
with cte8 as (
	SELECT t1.issueid
	FROM {SOURCE_SCHEMA}.drugissue as t1
	left join {SOURCE_SCHEMA}.staff as t2 on t1.staffid = t2.staffid
	WHERE t2.staffid is null
)
update {SOURCE_SCHEMA}.drugissue as t3
set staffid = null
from cte8 where t3.issueid = cte8.issueid;

-- OBSERVATION - MOVE UNACCEPTABLE AND UNEXISTENT PATIENTS. Unacceptable patients have already been removed from {SOURCE_SCHEMA}.patient, so we can remove both unexistent and acceptable at once.
CREATE TABLE {SOURCE_NOK_SCHEMA}.observation (LIKE {SOURCE_SCHEMA}.observation);

with cte9 as (
	SELECT t1.obsid
	FROM {SOURCE_SCHEMA}.observation as t1
	left join {SOURCE_SCHEMA}.patient as t2 on t1.patid = t2.patid
	WHERE t2.patid is null
)
INSERT INTO {SOURCE_NOK_SCHEMA}.observation
SELECT t1.* FROM {SOURCE_SCHEMA}.observation as t1
INNER JOIN cte9 on cte9.obsid = t1.obsid;

with cte10 as (
	SELECT t1.obsid
	FROM {SOURCE_SCHEMA}.observation as t1
	left join {SOURCE_SCHEMA}.patient as t2 on t1.patid = t2.patid
	WHERE t2.patid is null
)
DELETE FROM {SOURCE_SCHEMA}.observation as t3
USING cte10
WHERE t3.obsid = cte10.obsid;


-- OBSERVATION SET TO NULL unexistent staffids
with cte11 as (
	SELECT t1.obsid
	FROM {SOURCE_SCHEMA}.observation as t1
	left join {SOURCE_SCHEMA}.staff as t2 on t1.staffid = t2.staffid
	WHERE t2.staffid is null
)
update {SOURCE_SCHEMA}.observation as t3
set staffid = null
from cte11 
WHERE t3.obsid = cte11.obsid;

-- OBSERVATION SET TO NULL unexistent pracids
--POC	with t as (
--POC		SELECT t1.obsid
--POC		FROM {SOURCE_SCHEMA}.observation as t1
--POC		left join {SOURCE_SCHEMA}.practice as t2 on t1.pracid = t2.pracid
--POC		WHERE t2.pracid is null
--POC	)
--POC	update {SOURCE_SCHEMA}.observation as t3
--POC	set pracid = null
--POC	setfrom t where t3.obsid = t.obsid;

-- OBSERVATION - SET TO NULL unexistent parentobsid
--POC	with t as (
--POC		SELECT t1.obsid
--POC		FROM {SOURCE_SCHEMA}.observation as t1
--POC		left join {SOURCE_SCHEMA}.observation as t2 on t1.obsid = t2.parentobsid
--POC		WHERE t2.parentobsid is null
--POC	)
--POC	update {SOURCE_SCHEMA}.observation as t3
--POC	set parentobsid = null
--POC	from t where t3.obsid = t.obsid;

-- OBSERVATION SET TO NULL unexistent consultations
--POC	with t as (
--POC		SELECT t1.obsid
--POC		FROM {SOURCE_SCHEMA}.observation as t1
--POC		left join {SOURCE_SCHEMA}.consultation as t2 on t1.consid = t2.consid
--POC		WHERE t2.consid is null
--POC	)
--POC	update {SOURCE_SCHEMA}.observation as t3
--POC	set consid = null
--POC	setfrom t where t3.obsid = t.obsid;


-- OBSERVATION SET obsdate to consdate when obsdate is NULL and consdate is not NULL
with cte12 as (
	SELECT t1.obsid, t2.consdate
	FROM {SOURCE_SCHEMA}.observation as t1
	INNER JOIN {SOURCE_SCHEMA}.consultation as t2 on t1.patid = t2.patid and t1.consid = t2.consid
	WHERE t1.obsdate is null
	AND t2.consdate is not null
)
update {SOURCE_SCHEMA}.observation as t3
set obsdate = cte12.consdate
from cte12 
WHERE t3.obsid = cte12.obsid;

-- OBSERVATION - remove observations where obsdate is NULL 
with cte13 as (
	SELECT obsid
	FROM {SOURCE_SCHEMA}.observation
	WHERE obsdate is null
)
INSERT INTO {SOURCE_NOK_SCHEMA}.observation
SELECT t1.* 
FROM {SOURCE_SCHEMA}.observation as t1
INNER JOIN cte13 on cte13.obsid = t1.obsid;

with cte14 as (
	SELECT obsid
	FROM {SOURCE_SCHEMA}.observation
	WHERE obsdate is null
)
DELETE FROM {SOURCE_SCHEMA}.observation as t1
USING cte14
WHERE t1.obsid = cte14.obsid;


-- PROBLEM - MOVE UNACCEPTABLE AND UNEXISTENT PATIENTS. Unacceptable patients have already been removed from {SOURCE_SCHEMA}.patient, so we can remove both unexistent and acceptable at once.
CREATE TABLE {SOURCE_NOK_SCHEMA}.problem (LIKE {SOURCE_SCHEMA}.problem);

with cte15 as (
	SELECT t1.obsid
	FROM {SOURCE_SCHEMA}.problem as t1
	left join {SOURCE_SCHEMA}.patient as t2 on t1.patid = t2.patid
	WHERE t2.patid is null
)
INSERT INTO {SOURCE_NOK_SCHEMA}.problem
SELECT t1.* 
FROM {SOURCE_SCHEMA}.problem as t1
INNER JOIN cte15 on cte15.obsid = t1.obsid;

with cte16 as (
	SELECT t1.obsid
	FROM {SOURCE_SCHEMA}.problem as t1
	left join {SOURCE_SCHEMA}.patient as t2 on t1.patid = t2.patid
	WHERE t2.patid is null
)
DELETE FROM {SOURCE_SCHEMA}.problem as t3
USING cte16
WHERE t3.obsid = cte16.obsid;

-- PROBLEM SET TO NULL unexistent staffids

with cte17 as (
	SELECT t1.obsid
	FROM {SOURCE_SCHEMA}.problem as t1
	left join {SOURCE_SCHEMA}.staff as t2 on t1.lastrevstaffid = t2.staffid
	WHERE t2.staffid is null
)
update {SOURCE_SCHEMA}.problem as t3
set lastrevstaffid = null
from cte17 where t3.obsid = cte17.obsid;



-- REFERRAL - UNACCEPTABLE AND UNEXISTENT PATIENTS. Unacceptable patients have already been removed from {SOURCE_SCHEMA}.patient, so we can remove both unexistent and acceptable at once.
CREATE TABLE {SOURCE_NOK_SCHEMA}.referral (LIKE {SOURCE_SCHEMA}.referral);

with cte18 as (
	SELECT t1.obsid
	FROM {SOURCE_SCHEMA}.referral as t1
	left join {SOURCE_SCHEMA}.patient as t2 on t1.patid = t2.patid
	WHERE t2.patid is null
)
INSERT INTO {SOURCE_NOK_SCHEMA}.referral
SELECT t1.* 
FROM {SOURCE_SCHEMA}.referral as t1
INNER JOIN cte18 on cte18.obsid = t1.obsid;

with cte19 as (
	SELECT t1.obsid
	FROM {SOURCE_SCHEMA}.referral as t1
	left join {SOURCE_SCHEMA}.patient as t2 on t1.patid = t2.patid
	WHERE t2.patid is null
)
DELETE FROM {SOURCE_SCHEMA}.referral as t3
USING cte19
WHERE t3.obsid = cte19.obsid;
