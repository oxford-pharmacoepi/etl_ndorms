-- REFERRAL
alter table {SOURCE_SCHEMA}.referral add constraint pk_referral primary key (obsid) USING INDEX TABLESPACE pg_default;
create index idx_referral_patid on {SOURCE_SCHEMA}.referral(patid) TABLESPACE pg_default;
cluster {SOURCE_SCHEMA}.referral using idx_referral_patid;
create index idx_referral_refservicetypeid on {SOURCE_SCHEMA}.referral(refservicetypeid) TABLESPACE pg_default;
