-- PK should be (patid, attendid, primaryprocedureopcs, proceduredate), but the data are dirty and we added a dummy PK
ALTER table {SOURCE_SCHEMA}.rtds_opcds add constraint pk_rtds_opcds primary key (procedure_id) USING INDEX TABLESPACE pg_default;

CREATE INDEX idx_rtds_opcds ON {SOURCE_SCHEMA}.rtds_opcds (patid, attendid ASC) TABLESPACE pg_default;
CLUSTER {SOURCE_SCHEMA}.rtds_opcds USING idx_rtds_opcds;
