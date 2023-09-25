CREATE SCHEMA IF NOT EXISTS {SOURCE_SCHEMA};
CREATE SCHEMA IF NOT EXISTS {SOURCE_NOK_SCHEMA};
CREATE SCHEMA IF NOT EXISTS temp;
CREATE SCHEMA IF NOT EXISTS results;
CREATE SCHEMA IF NOT EXISTS scratch;

drop table if exists {SOURCE_SCHEMA}.test CASCADE;
drop table if exists {SOURCE_SCHEMA}.therapy CASCADE;
drop table if exists {SOURCE_SCHEMA}.referral CASCADE;
drop table if exists {SOURCE_SCHEMA}.additional CASCADE;
drop table if exists {SOURCE_SCHEMA}.clinical CASCADE;
drop table if exists {SOURCE_SCHEMA}.immunisation CASCADE;
drop table if exists {SOURCE_SCHEMA}.consultation CASCADE;
drop table if exists {SOURCE_SCHEMA}.patient CASCADE;
drop table if exists {SOURCE_SCHEMA}.staff CASCADE;
drop table if exists {SOURCE_SCHEMA}.practice CASCADE;
drop table if exists {SOURCE_SCHEMA}._records CASCADE;

drop table if exists {SOURCE_NOK_SCHEMA}.test CASCADE;
drop table if exists {SOURCE_NOK_SCHEMA}.therapy CASCADE;
drop table if exists {SOURCE_NOK_SCHEMA}.referral CASCADE;
drop table if exists {SOURCE_NOK_SCHEMA}.additional CASCADE;
drop table if exists {SOURCE_NOK_SCHEMA}.clinical CASCADE;
drop table if exists {SOURCE_NOK_SCHEMA}.immunisation CASCADE;
drop table if exists {SOURCE_NOK_SCHEMA}.consultation CASCADE;
drop table if exists {SOURCE_NOK_SCHEMA}.patient CASCADE;

