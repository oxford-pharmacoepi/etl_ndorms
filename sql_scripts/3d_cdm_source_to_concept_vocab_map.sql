DROP TABLE IF EXISTS {TARGET_SCHEMA}.SOURCE_TO_CONCEPT_MAP CASCADE;

CREATE TABLE {TARGET_SCHEMA}.SOURCE_TO_CONCEPT_MAP (

		source_code varchar(255) NOT NULL,
		source_concept_id integer NOT NULL,
		source_vocabulary_id varchar(20) NOT NULL,
		source_code_description varchar(255) NULL,
		target_concept_id integer NOT NULL,
		target_vocabulary_id varchar(20) NOT NULL,
		valid_start_date date NOT NULL,
		valid_end_date date NOT NULL,
		invalid_reason varchar(1) NULL );

COPY {TARGET_SCHEMA}.source_to_concept_map FROM '{STCM_DIRECTORY}\AURUM_JOB_CATEGORY_STCM.csv' WITH DELIMITER E',' CSV HEADER QUOTE E'"';

COPY {TARGET_SCHEMA}.source_to_concept_map FROM '{STCM_DIRECTORY}\AURUM_ROUTE_STCM.csv' WITH DELIMITER E',' CSV HEADER QUOTE E'"';

COPY {TARGET_SCHEMA}.source_to_concept_map FROM '{STCM_DIRECTORY}\AURUM_UNIT_STCM.csv' WITH DELIMITER E',' CSV HEADER QUOTE E'"';

-- COPY {TARGET_SCHEMA}.source_to_concept_map FROM '{STCM_DIRECTORY}\CONSULTATION_STCM.csv' WITH DELIMITER E',' CSV HEADER QUOTE E'"';

