--death 
alter table {SOURCE_SCHEMA}.death add constraint pk_death primary key (eid, ins_index) USING INDEX TABLESPACE pg_default;
