--STAFF
alter table {SOURCE_SCHEMA}.staff add constraint pk_staff primary key (staffid) USING INDEX TABLESPACE pg_default;
CREATE UNIQUE INDEX IF NOT EXISTS idx_staffid ON {SOURCE_SCHEMA}.staff(staffid ASC) TABLESPACE pg_default;
CLUSTER {SOURCE_SCHEMA}.staff USING idx_staffid;
create index idx_staff_jobid on {SOURCE_SCHEMA}.staff(jobcatid) TABLESPACE pg_default;
