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

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.cancer (
	eid				bigint 		not null,	
	p40005_i0		date,
	p40005_i1		date,
	p40005_i2		date,
	p40005_i3		date,
	p40005_i4		date,
	p40005_i5		date,
	p40005_i6		date,
	p40005_i7		date,
	p40005_i8		date,
	p40005_i9		date,
	p40005_i10		date,
	p40005_i11		date,
	p40005_i12		date,
	p40005_i13		date,
	p40005_i14		date,
	p40005_i15		date,
	p40005_i16		date,
	p40005_i17		date,
	p40005_i18		date,
	p40005_i19		date,
	p40005_i20		date,
	p40005_i21		date,
	p40006_i0		varchar(5),
	p40006_i1		varchar(5),
	p40006_i2		varchar(5),
	p40006_i3		varchar(5),
	p40006_i4		varchar(5),
	p40006_i5		varchar(5),
	p40006_i6		varchar(5),
	p40006_i7		varchar(5),
	p40006_i8		varchar(5),
	p40006_i9		varchar(5),
	p40006_i10		varchar(5),
	p40006_i11		varchar(5),
	p40006_i12		varchar(5),
	p40006_i13		varchar(5),
	p40006_i14		varchar(5),
	p40006_i15		varchar(5),
	p40006_i16		varchar(5),
	p40006_i17		varchar(5),
	p40006_i18		varchar(5),
	p40006_i19		varchar(5),
	p40006_i20		varchar(5),
	p40006_i21		varchar(5),
	p40008_i0		NUMERIC,
	p40008_i1		NUMERIC,
	p40008_i2		NUMERIC,
	p40008_i3		NUMERIC,
	p40008_i4		NUMERIC,
	p40008_i5		NUMERIC,
	p40008_i6		NUMERIC,
	p40008_i7		NUMERIC,
	p40008_i8		NUMERIC,
	p40008_i9		NUMERIC,
	p40008_i10		NUMERIC,
	p40008_i11		NUMERIC,
	p40008_i12		NUMERIC,
	p40008_i13		NUMERIC,
	p40008_i14		NUMERIC,
	p40008_i15		NUMERIC,
	p40008_i16		NUMERIC,
	p40008_i17		NUMERIC,
	p40008_i18		NUMERIC,
	p40008_i19		NUMERIC,
	p40008_i20		NUMERIC,
	p40008_i21		NUMERIC,
	p40009_i0		NUMERIC,
	p40011_i0 		varchar(6),
	p40011_i1 		varchar(6),
	p40011_i2 		varchar(6),
	p40011_i3 		varchar(6),
	p40011_i4 		varchar(6),
	p40011_i5 		varchar(6),
	p40011_i6 		varchar(6),
	p40011_i7 		varchar(6),
	p40011_i8 		varchar(6),
	p40011_i9 		varchar(6),
	p40011_i10 		varchar(6),
	p40011_i11 		varchar(6),
	p40011_i12 		varchar(6),
	p40011_i13 		varchar(6),
	p40011_i14 		varchar(6),
	p40011_i15 		varchar(6),
	p40011_i16 		varchar(6),
	p40011_i17 		varchar(6),
	p40011_i18 		varchar(6),
	p40011_i19 		varchar(6),
	p40011_i20 		varchar(6),
	p40011_i21 		varchar(6),
	p40012_i0		NUMERIC,
	p40012_i1		NUMERIC,
	p40012_i2		NUMERIC,
	p40012_i3		NUMERIC,
	p40012_i4		NUMERIC,
	p40012_i5		NUMERIC,
	p40012_i6		NUMERIC,
	p40012_i7		NUMERIC,
	p40012_i8		NUMERIC,
	p40012_i9		NUMERIC,
	p40012_i10		NUMERIC,
	p40012_i11		NUMERIC,
	p40012_i12		NUMERIC,
	p40012_i13		NUMERIC,
	p40012_i14		NUMERIC,
	p40012_i15		NUMERIC,
	p40012_i16		NUMERIC,
	p40012_i17		NUMERIC,
	p40012_i18		NUMERIC,
	p40012_i19		NUMERIC,
	p40012_i20		NUMERIC,
	p40012_i21		NUMERIC,
	p40013_i0		varchar(6),
	p40013_i1		varchar(6),
	p40013_i2		varchar(6),
	p40013_i3		varchar(6),
	p40013_i4		varchar(6),
	p40013_i5		varchar(6),
	p40013_i6		varchar(6),
	p40013_i7		varchar(6),
	p40013_i8		varchar(6),
	p40013_i9		varchar(6),
	p40013_i10		varchar(6),
	p40013_i11		varchar(6),
	p40013_i12		varchar(6),
	p40013_i13		varchar(6),
	p40013_i14		varchar(6),
	p40019_i0		NUMERIC,
	p40019_i1		NUMERIC,
	p40019_i2		NUMERIC,
	p40019_i3		NUMERIC,
	p40019_i4		NUMERIC,
	p40019_i5		NUMERIC,
	p40019_i6		NUMERIC,
	p40019_i7		NUMERIC,
	p40019_i8		NUMERIC,
	p40019_i9		NUMERIC,
	p40019_i10		NUMERIC,
	p40019_i11		NUMERIC,
	p40019_i12		NUMERIC,
	p40019_i13		NUMERIC,
	p40019_i14		NUMERIC,
	p40019_i15		NUMERIC,
	p40019_i16		NUMERIC,
	p40019_i17		NUMERIC,
	p40019_i18		NUMERIC,
	p40019_i19		NUMERIC,
	p40019_i20		NUMERIC,
	p40019_i21		NUMERIC,
	p40021_i0		varchar(4),
	p40021_i1		varchar(4),
	p40021_i2		varchar(4),
	p40021_i3		varchar(4),
	p40021_i4		varchar(4),
	p40021_i5		varchar(4),
	p40021_i6		varchar(4),
	p40021_i7		varchar(4),
	p40021_i8		varchar(4),
	p40021_i9		varchar(4),
	p40021_i10		varchar(4),
	p40021_i11		varchar(4),
	p40021_i12		varchar(4),
	p40021_i13		varchar(4),
	p40021_i14		varchar(4),
	p40021_i15		varchar(4),
	p40021_i16		varchar(4),
	p40021_i17		varchar(4),
	p40021_i18		varchar(4),
	p40021_i19		varchar(4),
	p40021_i20		varchar(4),
	p40021_i21		varchar(4)
)TABLESPACE pg_default;

--CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.covid19_result_england(
--	eid					bigint,
--	specdate			date,
--	spectype			int,
--	laboratory			int,
--	origin				int,
--	result				int,
--	acute				int,
--	hosaq				int,
--	reqorg				int
--)TABLESPACE pg_default;
	
--CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.covid19_result_scotland (
--	eid					bigint,
--	specdate			date,
--	laboratory			varchar(10),
--	source				int,
--	locauth				int,
--	result				int
--)TABLESPACE pg_default;

--CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.covid19_result_wales (
--	eid					bigint,
--	specdate			date,
--	spectype			int,
--	laboratory			int,
--	pattype				int,
--	perstype			int,
--	result				int
--)TABLESPACE pg_default;


--CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.covid19_vaccination (
--	eid					bigint,
--	source				varchar(10),
--	vacc_date			date,
--	product				varchar(10),
--	procedure			varchar(10),
--	procedure_uni		varchar(10)
--)TABLESPACE pg_default;


--CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.covid19_misc (
--	eid					bigint,
--	blood_group			varchar(10)
--)TABLESPACE pg_default;