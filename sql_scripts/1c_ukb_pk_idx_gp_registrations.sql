-- Information on participant registrations varies by data supplier, in that Vision (England) provided a single registration record per person 
-- while the other suppliers provided multiple records per participant, 
-- and a small number of participants with data in the TPP extract do not have a registration record. 
-- Therefore variable numbers of registration records are included in this release, reflecting the providers’ extracts.

-- Theorotically, a patient should register the service once on a single day. 
-- But I never see the real data, so I am not sure if I can make a PK as following.  
alter table {SOURCE_SCHEMA}.gp_registrations add constraint pk_gp_registrations primary key (eid, data_provider, reg_date) USING INDEX TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_gp_registrations_eid ON {SOURCE_SCHEMA}.gp_registrations (eid) TABLESPACE pg_default;
