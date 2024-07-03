alter table {SOURCE_SCHEMA}.death_cause add constraint pk_death_cause primary key (eid, ins_index, arr_index) USING INDEX TABLESPACE pg_default;
create index idx_death_eid_ins_idx on {SOURCE_SCHEMA}.death_cause(eid, ins_index) TABLESPACE pg_default;
create index idx_death_cause_level on {SOURCE_SCHEMA}.death_cause(level) TABLESPACE pg_default;