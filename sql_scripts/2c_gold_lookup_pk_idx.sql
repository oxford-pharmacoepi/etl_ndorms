-- batchnumber
alter table {SOURCE_SCHEMA}.batchnumber add constraint pk_batchnumber primary key (batch);
CREATE INDEX IF NOT EXISTS idx_batch_number ON {SOURCE_SCHEMA}.batchnumber (batch_number);

-- bnfcodes
alter table {SOURCE_SCHEMA}.bnfcodes add constraint pk_bnfcodes primary key (bnfcode);
CREATE INDEX IF NOT EXISTS idx_bnfcodes ON {SOURCE_SCHEMA}.bnfcodes (bnf, bnfcode);

-- common_dosages
alter table {SOURCE_SCHEMA}.common_dosages add constraint pk_cdosage primary key (dosageid);
CREATE INDEX IF NOT EXISTS idx_cdosage ON {SOURCE_SCHEMA}.common_dosages (dosageid, daily_dose); --We need this as daily_dose cannot be added to PK as can be null

-- entity
alter table {SOURCE_SCHEMA}.entity add constraint pk_entity primary key (enttype, filetype, data_fields);
CREATE INDEX IF NOT EXISTS idx_entity_enttype_data_fields ON {SOURCE_SCHEMA}.entity (enttype, data_fields);
CREATE INDEX IF NOT EXISTS idx_entity_data_fields ON {SOURCE_SCHEMA}.entity (data_fields);
CREATE INDEX IF NOT EXISTS idx_entity_data01 ON {SOURCE_SCHEMA}.entity (data1_lkup);
CREATE INDEX IF NOT EXISTS idx_entity_data02 ON {SOURCE_SCHEMA}.entity (data2_lkup);
CREATE INDEX IF NOT EXISTS idx_entity_data03 ON {SOURCE_SCHEMA}.entity (data3_lkup);
CREATE INDEX IF NOT EXISTS idx_entity_data04 ON {SOURCE_SCHEMA}.entity (data4_lkup);
CREATE INDEX IF NOT EXISTS idx_entity_data05 ON {SOURCE_SCHEMA}.entity (data5_lkup);
CREATE INDEX IF NOT EXISTS idx_entity_data06 ON {SOURCE_SCHEMA}.entity (data6_lkup);
CREATE INDEX IF NOT EXISTS idx_entity_data07 ON {SOURCE_SCHEMA}.entity (data7_lkup);
CREATE INDEX IF NOT EXISTS idx_entity_data08 ON {SOURCE_SCHEMA}.entity (data8_lkup);
CREATE INDEX IF NOT EXISTS idx_entity_data09 ON {SOURCE_SCHEMA}.entity (data9_lkup);
CREATE INDEX IF NOT EXISTS idx_entity_data10 ON {SOURCE_SCHEMA}.entity (data10_lkup);
CREATE INDEX IF NOT EXISTS idx_entity_data11 ON {SOURCE_SCHEMA}.entity (data11_lkup);
CREATE INDEX IF NOT EXISTS idx_entity_data12 ON {SOURCE_SCHEMA}.entity (data12_lkup);

-- lookup
alter table {SOURCE_SCHEMA}.lookup add constraint pk_lookup primary key (lookup_id, lookup_type_id, code);
CREATE INDEX IF NOT EXISTS idx_lookup ON {SOURCE_SCHEMA}.lookup (lookup_type_id);
CREATE INDEX IF NOT EXISTS idx_lookup_code ON {SOURCE_SCHEMA}.lookup (code);

-- lookuptype
alter table {SOURCE_SCHEMA}.lookuptype add constraint pk_lookuptype primary key (lookup_type_id, name);
CREATE INDEX IF NOT EXISTS idx_lookuptype_name ON {SOURCE_SCHEMA}.lookuptype (name);

-- medical
alter table {SOURCE_SCHEMA}.medical add constraint pk_medical primary key (medcode);
CREATE INDEX IF NOT EXISTS idx_medical ON {SOURCE_SCHEMA}.medical (medcode, readcode); --We need this as readcode cannot be added to PK as can be null (when medcode = 0)

-- product
alter table {SOURCE_SCHEMA}.product add constraint pk_product primary key (prodcode);

-- packtype
alter table {SOURCE_SCHEMA}.packtype add constraint pk_packtype primary key (packtype);

-- scoremethod
alter table {SOURCE_SCHEMA}.scoremethod add constraint pk_scoremethod primary key (code);