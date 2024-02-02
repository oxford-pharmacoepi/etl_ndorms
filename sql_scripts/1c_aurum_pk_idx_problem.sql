--PROBLEM
alter table {SOURCE_SCHEMA}.problem add constraint pk_problem primary key (obsid) USING INDEX TABLESPACE pg_default;
create index idx_problem_patid on {SOURCE_SCHEMA}.problem(patid) TABLESPACE pg_default;
cluster {SOURCE_SCHEMA}.problem using idx_problem_patid;
create index idx_problem_staffid on {SOURCE_SCHEMA}.problem(lastrevstaffid) TABLESPACE pg_default;
