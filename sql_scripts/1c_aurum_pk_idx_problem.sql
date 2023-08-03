--PROBLEM
alter table {SOURCE_SCHEMA}.problem add constraint pk_problem primary key (obsid);
create index idx_problem_patid on {SOURCE_SCHEMA}.problem(patid);
cluster {SOURCE_SCHEMA}.problem using idx_problem_patid;
create index idx_problem_staffid on {SOURCE_SCHEMA}.problem(lastrevstaffid);
