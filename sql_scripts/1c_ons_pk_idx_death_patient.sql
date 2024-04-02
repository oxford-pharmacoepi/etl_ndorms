alter table {SOURCE_SCHEMA}.death_patient add constraint pk_death_patient primary key (patid) USING INDEX TABLESPACE pg_default;
create index idx_dpatient_match_rank on {SOURCE_SCHEMA}.death_patient(match_rank) TABLESPACE pg_default;
create index idx_dpatient_cause on {SOURCE_SCHEMA}.death_patient(cause) TABLESPACE pg_default;