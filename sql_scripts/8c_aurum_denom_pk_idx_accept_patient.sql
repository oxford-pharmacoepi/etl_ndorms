--Aurum_AcceptablePats
alter table {SOURCE_SCHEMA}.aurum_acceptablepats add constraint pk_accept_pat primary key (patid, gender, yob, acceptable);
create index idx_accept_pat_pracid on {SOURCE_SCHEMA}.aurum_acceptablepats(pracid);
