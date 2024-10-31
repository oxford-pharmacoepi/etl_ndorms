------------------------------------
-- reform the cancer table structure
------------------------------------
DROP TABLE IF EXISTS {SOURCE_SCHEMA}.cancer2 CASCADE;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.cancer2 (
	id 				BIGSERIAL 	NOT NULL,
	eid				bigint 		not null,	
	p40005			date,
	p40006			varchar(5),
	p40008			NUMERIC,
	p40009			integer,			--Reported occurrences of cancer
	p40011			varchar(4),			--Histology of cancer tumour
	p40012			integer,			--Behaviour of cancer tumour
	p40013			varchar(6),
	p40019			integer,			--Cancer record format
	p40021			varchar(4)			--Data-Coding 262: Cancer information source
)TABLESPACE pg_default;

ALTER TABLE {SOURCE_SCHEMA}.cancer2 SET (autovacuum_enabled = False);

With cte as(
select 
	eid,
	unnest(array[p40005_i0::TEXT, p40005_i1::TEXT, p40005_i2::TEXT, p40005_i3::TEXT, p40005_i4::TEXT, 
				 p40005_i5::TEXT, p40005_i6::TEXT, p40005_i7::TEXT, p40005_i8::TEXT, p40005_i9::TEXT, 
				 p40005_i10::TEXT,p40005_i11::TEXT,p40005_i12::TEXT,p40005_i13::TEXT,p40005_i14::TEXT,
				 p40005_i15::TEXT,p40005_i16::TEXT,p40005_i17::TEXT,p40005_i18::TEXT,p40005_i19::TEXT,
				 p40005_i20::TEXT,p40005_i21::TEXT]) as p40005,
	unnest(array[p40006_i0::TEXT, p40006_i1::TEXT, p40006_i2::TEXT, p40006_i3::TEXT, p40006_i4::TEXT,
				 p40006_i5::TEXT, p40006_i6::TEXT, p40006_i7::TEXT, p40006_i8::TEXT, p40006_i9::TEXT,
				 p40006_i10::TEXT,p40006_i11::TEXT, p40006_i12::TEXT, p40006_i13::TEXT, p40006_i14::TEXT,
				 p40006_i15::TEXT,p40006_i16::TEXT, p40006_i17::TEXT, p40006_i18::TEXT, p40006_i19::TEXT,
				 p40006_i20::TEXT,p40006_i21::TEXT]) as p40006,
	unnest(array[p40008_i0::TEXT, p40008_i1::TEXT, p40008_i2::TEXT, p40008_i3::TEXT, p40008_i4::TEXT,
				 p40008_i5::TEXT, p40008_i6::TEXT, p40008_i7::TEXT, p40008_i8::TEXT, p40008_i9::TEXT,
				 p40008_i10::TEXT,p40008_i11::TEXT,p40008_i12::TEXT, p40008_i13::TEXT, p40008_i14::TEXT,
				 p40008_i15::TEXT,p40008_i16::TEXT,p40008_i17::TEXT, p40008_i18::TEXT, p40008_i19::TEXT,
				 p40008_i20::TEXT,p40008_i21::TEXT]) as p40008,
	p40009_i0 as p40009,
	unnest(array[p40011_i0::TEXT, p40011_i1::TEXT, p40011_i2::TEXT, p40011_i3::TEXT, p40011_i4::TEXT,
				 p40011_i5::TEXT, p40011_i6::TEXT, p40011_i7::TEXT, p40011_i8::TEXT, p40011_i9::TEXT,
				 p40011_i10::TEXT,p40011_i11::TEXT,p40011_i12::TEXT,p40011_i13::TEXT,p40011_i14::TEXT,
				 p40011_i15::TEXT,p40011_i16::TEXT,p40011_i17::TEXT,p40011_i18::TEXT,p40011_i19::TEXT,
				 p40011_i20::TEXT, p40011_i21::TEXT]) as p40011,
	unnest(array[p40012_i0::TEXT, p40012_i1::TEXT, p40012_i2::TEXT, p40012_i3::TEXT, p40012_i4::TEXT,
				 p40012_i5::TEXT, p40012_i6::TEXT, p40012_i7::TEXT, p40012_i8::TEXT, p40012_i9::TEXT,
				 p40012_i10::TEXT,p40012_i11::TEXT,p40012_i12::TEXT,p40012_i13::TEXT,p40012_i14::TEXT,
				 p40012_i15::TEXT,p40012_i16::TEXT,p40012_i17::TEXT,p40012_i18::TEXT,p40012_i19::TEXT,
				 p40012_i20::TEXT, p40012_i21::TEXT]) as p40012,
	unnest(array[p40013_i0::TEXT, p40013_i1::TEXT, p40013_i2::TEXT, p40013_i3::TEXT, p40013_i4::TEXT,
				 p40013_i5::TEXT, p40013_i6::TEXT, p40013_i7::TEXT, p40013_i8::TEXT, p40013_i9::TEXT,
				 p40013_i10::TEXT,p40013_i11::TEXT,p40013_i12::TEXT,p40013_i13::TEXT,p40013_i14::TEXT]) as p40013,
	unnest(array[p40019_i0::TEXT, p40019_i1::TEXT, p40019_i2::TEXT, p40019_i3::TEXT, p40019_i4::TEXT,
				 p40019_i5::TEXT, p40019_i6::TEXT, p40019_i7::TEXT, p40019_i8::TEXT, p40019_i9::TEXT,
				 p40019_i10::TEXT,p40019_i11::TEXT,p40019_i12::TEXT,p40019_i13::TEXT,p40019_i14::TEXT,
				 p40019_i15::TEXT,p40019_i16::TEXT,p40019_i17::TEXT,p40019_i18::TEXT,p40019_i19::TEXT,
				 p40019_i20::TEXT, p40019_i21::TEXT]) as p40019,
	unnest(array[p40021_i0::TEXT, p40021_i1::TEXT, p40021_i2::TEXT, p40021_i3::TEXT, p40021_i4::TEXT,
				 p40021_i5::TEXT, p40021_i6::TEXT, p40021_i7::TEXT, p40021_i8::TEXT, p40021_i9::TEXT,
				 p40021_i10::TEXT,p40021_i11::TEXT,p40021_i12::TEXT,p40021_i13::TEXT,p40021_i14::TEXT,
				 p40021_i15::TEXT,p40021_i16::TEXT,p40021_i17::TEXT,p40021_i18::TEXT,p40021_i19::TEXT,
				 p40021_i20::TEXT, p40021_i21::TEXT]) as p40021
from {SOURCE_SCHEMA}.cancer
)
insert into {SOURCE_SCHEMA}.cancer2(eid, p40005, p40006, p40008, p40009, p40011, p40012, p40013, p40019, p40021)
select 
	eid, 
	p40005::date, 
	p40006,
	p40008::numeric,
	p40009,
	LEFT(p40011, 4),
	p40012::numeric,
	p40013,
	p40019::numeric,
	p40021
from cte;

alter table {SOURCE_SCHEMA}.cancer2 add constraint pk_cancer2 primary key (id) USING INDEX TABLESPACE pg_default;

------------------------------------
-- curation
------------------------------------

DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.cancer2 CASCADE;

DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.baseline CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.death CASCADE;

CREATE TABLE {SOURCE_NOK_SCHEMA}.cancer2 (LIKE {SOURCE_SCHEMA}.cancer2) TABLESPACE pg_default;

CREATE TABLE {SOURCE_NOK_SCHEMA}.baseline (LIKE {SOURCE_SCHEMA}.baseline) TABLESPACE pg_default;
CREATE TABLE {SOURCE_NOK_SCHEMA}.death (LIKE {SOURCE_SCHEMA}.death) TABLESPACE pg_default;

--------------------------------
-- cancer2
--------------------------------
INSERT INTO {SOURCE_NOK_SCHEMA}.cancer2(
	select * from {SOURCE_SCHEMA}.cancer2
	where p40005 is NULL
	and p40006 is NULL			-- Type of cancer: ICD10
	and p40011 is NULL 			-- Histology of cancer tumour is null
	and p40012 is NULL 
	and p40013 is NULL 			-- Type of cancer: ICD9
);

alter table {SOURCE_NOK_SCHEMA}.cancer2 add constraint pk_cancer2_nok primary key (id) USING INDEX TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.cancer2 as t1 
using {SOURCE_NOK_SCHEMA}.cancer2 as t2
WHERE t1.id = t2.id;

VACUUM (ANALYZE) {SOURCE_SCHEMA}.cancer2;
ALTER TABLE {SOURCE_SCHEMA}.cancer2 SET (autovacuum_enabled = True);

--------------------------------
-- baseline
--------------------------------
INSERT INTO {SOURCE_NOK_SCHEMA}.baseline
select t1.*
from {SOURCE_SCHEMA}.baseline as t1
left join {SOURCE_SCHEMA}.cancer2 as t2 on t1.eid = t2.eid
where t2.eid is null;

alter table {SOURCE_NOK_SCHEMA}.baseline add constraint pk_baseline_nok primary key (eid) USING INDEX TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.baseline as t1 
using {SOURCE_NOK_SCHEMA}.baseline as t2
WHERE t1.eid = t2.eid;

--------------------------------
-- death
--------------------------------
INSERT INTO {SOURCE_NOK_SCHEMA}.death
select t1.*
from {SOURCE_SCHEMA}.death as t1
join {SOURCE_NOK_SCHEMA}.baseline as t2 on t1.eid = t2.eid; 

alter table {SOURCE_NOK_SCHEMA}.death add constraint pk_death primary key (eid, ins_index) USING INDEX TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.death as t1 
using {SOURCE_NOK_SCHEMA}.death as t2
WHERE t1.eid = t2.eid
and t1.ins_index = t2.ins_index;

-- create index in cancer2
create index idx_cancer2_1 on {SOURCE_SCHEMA}.cancer2(eid) TABLESPACE pg_default;
create index idx_cancer2_2 on {SOURCE_SCHEMA}.cancer2(p40011, p40012, p40006) TABLESPACE pg_default;
create index idx_cancer2_3 on {SOURCE_SCHEMA}.cancer2(p40011, p40012, p40013) TABLESPACE pg_default;
create index idx_cancer2_4 on {SOURCE_SCHEMA}.cancer2(p40006) TABLESPACE pg_default;
create index idx_cancer2_5 on {SOURCE_SCHEMA}.cancer2(p40013) TABLESPACE pg_default;