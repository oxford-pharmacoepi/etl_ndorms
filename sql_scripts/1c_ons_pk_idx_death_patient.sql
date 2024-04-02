alter table {SOURCE_SCHEMA}.ons_death add constraint pk_ons_death primary key (patid) USING INDEX TABLESPACE pg_default;
create index idx_dpatient_match_rank on {SOURCE_SCHEMA}.ons_death(match_rank) TABLESPACE pg_default;
create index idx_dpatient_cause on {SOURCE_SCHEMA}.ons_death(cause) TABLESPACE pg_default;