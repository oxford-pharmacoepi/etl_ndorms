--PATIENT
alter table {SOURCE_SCHEMA}.patient add constraint pk_patient primary key (patid) USING INDEX TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS idx_patid ON {SOURCE_SCHEMA}.patient(patid ASC) TABLESPACE pg_default;
CLUSTER {SOURCE_SCHEMA}.patient USING idx_patid;

create index idx_patient_staffid on {SOURCE_SCHEMA}.patient(usualgpstaffid) TABLESPACE pg_default;

