CREATE TABLE IF NOT EXISTS  {LINKAGE_SCHEMA}.patient_townsend
(
	patid bigint NOT NULL,
	pracid int NOT NULL,
    uk2011_townsend_10 smallint DEFAULT NULL
) TABLESPACE pg_default;
