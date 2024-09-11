CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.linkage_coverage
(
	data_source varchar(10) NOT NULL,
	"start" DATE NOT NULL,
	"end" DATE NOT NULL
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.ons_death (
	patid				bigint,
	pracid				int,
	gen_death_id		bigint,
	n_patid_death		int,
	match_rank			int,
	dor					date,
	dod					date,
	dod_partial			varchar(10),
	nhs_indicator		int,
	pod_category		varchar(25),
	cause				varchar(6),
	cause1				varchar(6),
	cause2				varchar(6),
	cause3				varchar(6),
	cause4				varchar(6),
	cause5				varchar(6),
	cause6				varchar(6),
	cause7				varchar(6),
	cause8				varchar(6),
	cause9				varchar(6),
	cause10				varchar(6),
	cause11				varchar(6),
	cause12				varchar(6),
	cause13				varchar(6),
	cause14				varchar(6),
	cause15				varchar(6),
	cause_neonatal1		varchar(6),
	cause_neonatal2		varchar(6),
	cause_neonatal3		varchar(6),
	cause_neonatal4		varchar(6),
	cause_neonatal5		varchar(6),
	cause_neonatal6		varchar(6),
	cause_neonatal7		varchar(6),
	cause_neonatal8		varchar(6)
)TABLESPACE pg_default;