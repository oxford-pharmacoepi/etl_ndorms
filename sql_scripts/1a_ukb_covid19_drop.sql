---Dropping all UKBioBank - COVID19 Tables ---------------------------------------
drop table if exists {SOURCE_SCHEMA}.covid19_result_england_row1 CASCADE;
drop table if exists {SOURCE_SCHEMA}.covid19_result_scotland_row1 CASCADE;
drop table if exists {SOURCE_SCHEMA}.covid19_result_wales_row1 CASCADE;
drop table if exists {SOURCE_SCHEMA}.covid19_vaccination_row1 CASCADE;
drop table if exists {SOURCE_SCHEMA}.covid19_misc_row1 CASCADE;