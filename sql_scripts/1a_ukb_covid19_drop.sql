---Dropping all UKBioBank - COVID19 Tables ---------------------------------------
drop table if exists {SOURCE_SCHEMA}.covid19_result_england CASCADE;
drop table if exists {SOURCE_SCHEMA}.covid19_result_scotland CASCADE;
drop table if exists {SOURCE_SCHEMA}.covid19_result_wales CASCADE;
drop table if exists {SOURCE_SCHEMA}.covid19_vaccination CASCADE;
drop table if exists {SOURCE_SCHEMA}.covid19_misc CASCADE;