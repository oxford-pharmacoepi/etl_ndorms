---Dropping all BioBank HES Tables ---------------------------------------
drop table if exists {SOURCE_SCHEMA}.hesin CASCADE;
drop table if exists {SOURCE_SCHEMA}.hesin_critical CASCADE;
drop table if exists {SOURCE_SCHEMA}.hesin_delivery CASCADE;
drop table if exists {SOURCE_SCHEMA}.hesin_diag CASCADE;
drop table if exists {SOURCE_SCHEMA}.hesin_maternity CASCADE;
drop table if exists {SOURCE_SCHEMA}.hesin_oper CASCADE;
drop table if exists {SOURCE_SCHEMA}.hesin_psych CASCADE;