alter table {SOURCE_SCHEMA}.baseline add constraint pk_baseline primary key (eid) USING INDEX TABLESPACE pg_default;
create index idx_baseline_idx_1 on {SOURCE_SCHEMA}.baseline(p31) TABLESPACE pg_default;
create index idx_baseline_idx_2 on {SOURCE_SCHEMA}.baseline(p21000_i0) TABLESPACE pg_default;