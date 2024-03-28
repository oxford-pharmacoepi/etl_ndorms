--postgresql CDM DDL Specification for OMOP Common Data Model v5_3_1 

--HINT DISTRIBUTE ON KEY (person_id)
 CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.DEATH_ONS (
 			person_id bigint NOT NULL,
			death_date date NOT NULL,
			death_datetime TIMESTAMP NULL,
			death_type_concept_id integer NULL,
			cause_concept_id integer NULL,
			cause_source_value varchar(50) NULL,
			cause_source_concept_id integer NULL 
)TABLESPACE pg_default;
