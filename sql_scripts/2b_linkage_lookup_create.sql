CREATE TABLE IF NOT EXISTS {LINKAGE_SCHEMA}.linkage_coverage
(
	data_source varchar(10) NOT NULL,
	"start" DATE NOT NULL,
	"end" DATE NOT NULL
) TABLESPACE pg_default;
