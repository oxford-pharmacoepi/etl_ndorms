--hes_episodes
alter table {SOURCE_SCHEMA}.hes_episodes add constraint pk_hes_episodes primary key (patid, epikey);
-- create index idx_hesapc_episodes_patid on {SOURCE_SCHEMA}.hes_episodes (patid);
cluster {SOURCE_SCHEMA}.hes_episodes using idx_hesapc_episodes_patid;
create index idx_hesapc_episodes_spno_patid on {SOURCE_SCHEMA}.hes_episodes (patid, spno);

create index idx_hesapc_pconsult on {SOURCE_SCHEMA}.hes_episodes (pconsult, tretspef);