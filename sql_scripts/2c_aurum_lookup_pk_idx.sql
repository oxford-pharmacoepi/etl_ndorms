-- gender
alter table {SOURCE_SCHEMA}.gender add constraint pk_gender primary key (genderid) USING INDEX TABLESPACE pg_default;

-- region
alter table {SOURCE_SCHEMA}.region add constraint pk_region primary key (regionid) USING INDEX TABLESPACE pg_default;

-- numunit
alter table {SOURCE_SCHEMA}.numunit add constraint pk_numunit primary key (numunitid) USING INDEX TABLESPACE pg_default;

-- quantunit
alter table {SOURCE_SCHEMA}.quantunit add constraint pk_quantunit primary key (quantunitid) USING INDEX TABLESPACE pg_default;

-- refservicetype
alter table {SOURCE_SCHEMA}.refservicetype add constraint pk_refservicetype primary key (refservicetypeid) USING INDEX TABLESPACE pg_default;

-- jobcat
alter table {SOURCE_SCHEMA}.jobcat add constraint pk_jobcat primary key (jobcatid) USING INDEX TABLESPACE pg_default;

-- productdictionary
alter table {SOURCE_SCHEMA}.productdictionary add constraint pk_productdictionary primary key (prodcodeid) USING INDEX TABLESPACE pg_default;

-- medicaldictionary
alter table {SOURCE_SCHEMA}.medicaldictionary add constraint pk_medicaldictionary primary key (medcodeid) USING INDEX TABLESPACE pg_default;
create index idx_medicaldictionary_rcode on {SOURCE_SCHEMA}.medicaldictionary (cleansedreadcode) TABLESPACE pg_default;
create index idx_medicaldictionary_snomed on {SOURCE_SCHEMA}.medicaldictionary (snomedctconceptid) TABLESPACE pg_default;

--VisionToEmisMigrators
alter table {SOURCE_SCHEMA}.visiontoemismigrators add constraint pk_visiontoemismigrators primary key (gold_pracid) USING INDEX TABLESPACE pg_default;

--common_dosages
alter table {SOURCE_SCHEMA}.common_dosages add constraint pk_common_dosages primary key (dosageid) USING INDEX TABLESPACE pg_default;

--patienttype
alter table {SOURCE_SCHEMA}.patienttype add constraint pk_patienttype primary key (patienttypeid) USING INDEX TABLESPACE pg_default;

--conssource
alter table {SOURCE_SCHEMA}.conssource add constraint pk_conssource primary key (id) USING INDEX TABLESPACE pg_default;

--refurgency
alter table {SOURCE_SCHEMA}.refurgency add constraint pk_refurgency primary key (refurgencyid) USING INDEX TABLESPACE pg_default;

--refmode
alter table {SOURCE_SCHEMA}.refmode add constraint pk_refmode primary key (refmodeid) USING INDEX TABLESPACE pg_default;

--parentprobrel
alter table {SOURCE_SCHEMA}.parentprobrel add constraint pk_parentprobrel primary key (parentprobrelid) USING INDEX TABLESPACE pg_default;

--probstatus
alter table {SOURCE_SCHEMA}.probstatus add constraint pk_probstatus primary key (probstatusid) USING INDEX TABLESPACE pg_default;

--sign
alter table {SOURCE_SCHEMA}.sign add constraint pk_sign primary key (signid) USING INDEX TABLESPACE pg_default;

--emiscodecat
alter table {SOURCE_SCHEMA}.emiscodecat add constraint pk_emiscodecat primary key (emiscodecatid) USING INDEX TABLESPACE pg_default;

--obstype
alter table {SOURCE_SCHEMA}.obstype add constraint pk_obstype primary key (obstypeid) USING INDEX TABLESPACE pg_default;
