---Dropping all BioBank HES Tables ---------------------------------------
drop table if exists {SOURCE_SCHEMA}.biob_hesin CASCADE;
drop table if exists {SOURCE_SCHEMA}.biob_hesin_critical CASCADE;
drop table if exists {SOURCE_SCHEMA}.biob_hesin_delivery CASCADE;
drop table if exists {SOURCE_SCHEMA}.biob_hesin_diag CASCADE;
drop table if exists {SOURCE_SCHEMA}.biob_hesin_maternity CASCADE;
drop table if exists {SOURCE_SCHEMA}.biob_hesin_oper CASCADE;
drop table if exists {SOURCE_SCHEMA}.biob_hesin_psych CASCADE;