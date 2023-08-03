--STAFF
alter table {SOURCE_SCHEMA}.staff add constraint pk_sfatt primary key (staffid);
create index idx_staff_jobid on {SOURCE_SCHEMA}.staff(jobcatid);
