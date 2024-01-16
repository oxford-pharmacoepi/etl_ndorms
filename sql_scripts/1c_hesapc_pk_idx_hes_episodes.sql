--hes_episodes
alter table {SOURCE_SCHEMA}.hes_episodes add constraint pk_hes_episodes primary key (patid, epikey) USING INDEX TABLESPACE pg_default;
create index idx_hesapc_episodes_patid on {SOURCE_SCHEMA}.hes_episodes (patid, epikey) TABLESPACE pg_default;
cluster {SOURCE_SCHEMA}.hes_episodes using idx_hesapc_episodes_patid;
create index idx_hesapc_episodes_patid_spno on {SOURCE_SCHEMA}.hes_episodes (patid, spno) TABLESPACE pg_default;

create index idx_hesapc_pconsult on {SOURCE_SCHEMA}.hes_episodes (pconsult, tretspef, mainspef) TABLESPACE pg_default;
