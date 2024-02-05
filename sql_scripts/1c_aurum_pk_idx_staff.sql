--STAFF
alter table {SOURCE_SCHEMA}.staff add constraint pk_sfatt primary key (staffid) USING INDEX TABLESPACE pg_default;
create index idx_staff_jobid on {SOURCE_SCHEMA}.staff(jobcatid) TABLESPACE pg_default;
