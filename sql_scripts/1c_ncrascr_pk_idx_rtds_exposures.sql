-- PK should be (patid, attendid, timeofexposure), but the data are dirty and we added a dummy PK
ALTER table {SOURCE_SCHEMA}.rtds_exposures add constraint pk_rtds_exposures primary key (exposure_id) USING INDEX TABLESPACE pg_default;

CREATE INDEX idx_rtds_exposures ON {SOURCE_SCHEMA}.rtds_exposures (patid, attendid ASC) TABLESPACE pg_default;
CLUSTER {SOURCE_SCHEMA}.rtds_exposures USING idx_rtds_exposures;
