--postgresql CDM DDL Specification for OMOP Common Data Model 5.4

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.PERSON (
			person_id bigint NOT NULL,
			gender_concept_id integer NOT NULL,
			year_of_birth integer NOT NULL,
			month_of_birth integer NULL,
			day_of_birth integer NULL,
			birth_datetime TIMESTAMP NULL,
			race_concept_id integer NOT NULL,
			ethnicity_concept_id integer NOT NULL,
			location_id bigint NULL,
			provider_id bigint NULL,
			care_site_id integer NULL,
			person_source_value varchar(50) NULL,
			gender_source_value varchar(50) NULL,
			gender_source_concept_id integer NULL,
			race_source_value varchar(50) NULL,
			race_source_concept_id integer NULL,
			ethnicity_source_value varchar(50) NULL,
			ethnicity_source_concept_id integer NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.OBSERVATION_PERIOD (
			observation_period_id bigint NOT NULL,
			person_id bigint NOT NULL,
			observation_period_start_date date NOT NULL,
			observation_period_end_date date NOT NULL,
			period_type_concept_id integer NOT NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.VISIT_OCCURRENCE (
			visit_occurrence_id bigint NOT NULL,
			person_id bigint NOT NULL,
			visit_concept_id integer NOT NULL,
			visit_start_date date NOT NULL,
			visit_start_datetime TIMESTAMP NULL,
			visit_end_date date NOT NULL,
			visit_end_datetime TIMESTAMP NULL,
			visit_type_concept_id integer NOT NULL,
			provider_id bigint NULL,
			care_site_id integer NULL,
			visit_source_value varchar(50) NULL,
			visit_source_concept_id integer NULL,
			admitted_from_concept_id integer NULL,
			admitted_from_source_value varchar(50) NULL,
			discharged_to_concept_id integer NULL,
			discharged_to_source_value varchar(50) NULL,
			preceding_visit_occurrence_id bigint NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.VISIT_DETAIL (
			visit_detail_id bigint NOT NULL,
			person_id bigint NOT NULL,
			visit_detail_concept_id integer NOT NULL,
			visit_detail_start_date date NOT NULL,
			visit_detail_start_datetime TIMESTAMP NULL,
			visit_detail_end_date date NOT NULL,
			visit_detail_end_datetime TIMESTAMP NULL,
			visit_detail_type_concept_id integer NOT NULL,
			provider_id bigint NULL,
			care_site_id integer NULL,
			visit_detail_source_value varchar(50) NULL,
			visit_detail_source_concept_id integer NULL,
			admitted_from_concept_id integer NULL,
			admitted_from_source_value varchar(100) NULL,
			discharged_to_source_value varchar(100) NULL,
			discharged_to_concept_id integer NULL,
			preceding_visit_detail_id bigint NULL,
			parent_visit_detail_id bigint NULL,
			visit_occurrence_id bigint NOT NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.CONDITION_OCCURRENCE (
			condition_occurrence_id bigint NOT NULL,
			person_id bigint NOT NULL,
			condition_concept_id integer NOT NULL,
			condition_start_date date NOT NULL,
			condition_start_datetime TIMESTAMP NULL,
			condition_end_date date NULL,
			condition_end_datetime TIMESTAMP NULL,
			condition_type_concept_id integer NOT NULL,
			condition_status_concept_id integer NULL,
			stop_reason varchar(20) NULL,
			provider_id bigint NULL,
			visit_occurrence_id bigint NULL,
			visit_detail_id bigint NULL,
			condition_source_value varchar(250) NULL,
			condition_source_concept_id integer NULL,
			condition_status_source_value varchar(50) NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.DRUG_EXPOSURE (
			drug_exposure_id bigint NOT NULL,
			person_id bigint NOT NULL,
			drug_concept_id integer NOT NULL,
			drug_exposure_start_date date NOT NULL,
			drug_exposure_start_datetime TIMESTAMP NULL,
			drug_exposure_end_date date NOT NULL,
			drug_exposure_end_datetime TIMESTAMP NULL,
			verbatim_end_date date NULL,
			drug_type_concept_id integer NOT NULL,
			stop_reason varchar(20) NULL,
			refills integer NULL,
			quantity NUMERIC NULL,
			days_supply integer NULL,
			sig TEXT NULL,
			route_concept_id integer NULL,
			lot_number varchar(50) NULL,
			provider_id bigint NULL,
			visit_occurrence_id bigint NULL,
			visit_detail_id bigint NULL,
			drug_source_value varchar(250) NULL,
			drug_source_concept_id integer NULL,
			route_source_value varchar(100) NULL,
			dose_unit_source_value varchar(50) NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.PROCEDURE_OCCURRENCE (
			procedure_occurrence_id bigint NOT NULL,
			person_id bigint NOT NULL,
			procedure_concept_id integer NOT NULL,
			procedure_date date NOT NULL,
			procedure_datetime TIMESTAMP NULL,
			procedure_end_date date NULL,
			procedure_end_datetime TIMESTAMP NULL,
			procedure_type_concept_id integer NOT NULL,
			modifier_concept_id integer NULL,
			quantity integer NULL,
			provider_id bigint NULL,
			visit_occurrence_id bigint NULL,
			visit_detail_id bigint NULL,
			procedure_source_value varchar(250) NULL,
			procedure_source_concept_id integer NULL,
			modifier_source_value varchar(50) NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.DEVICE_EXPOSURE (
			device_exposure_id bigint NOT NULL,
			person_id bigint NOT NULL,
			device_concept_id integer NOT NULL,
			device_exposure_start_date date NOT NULL,
			device_exposure_start_datetime TIMESTAMP NULL,
			device_exposure_end_date date NULL,
			device_exposure_end_datetime TIMESTAMP NULL,
			device_type_concept_id integer NOT NULL,
			unique_device_id varchar(255) NULL,
			production_id varchar(255) NULL,
			quantity integer NULL,
			provider_id bigint NULL,
			visit_occurrence_id bigint NULL,
			visit_detail_id bigint NULL,
			device_source_value varchar(250) NULL,
			device_source_concept_id integer NULL,
			unit_concept_id integer NULL,
			unit_source_value varchar(75) NULL,
			unit_source_concept_id integer NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.MEASUREMENT (
			measurement_id bigint NOT NULL,
			person_id bigint NOT NULL,
			measurement_concept_id integer NOT NULL,
			measurement_date date NOT NULL,
			measurement_datetime TIMESTAMP NULL,
			measurement_time varchar(10) NULL,
			measurement_type_concept_id integer NOT NULL,
			operator_concept_id integer NULL,
			value_as_number NUMERIC NULL,
			value_as_concept_id integer NULL,
			unit_concept_id integer NULL,
			range_low NUMERIC NULL,
			range_high NUMERIC NULL,
			provider_id bigint NULL,
			visit_occurrence_id bigint NULL,
			visit_detail_id bigint NULL,
			measurement_source_value varchar(250) NULL,
			measurement_source_concept_id integer NULL,
			unit_source_value varchar(60) NULL,
			unit_source_concept_id integer NULL,
			value_source_value varchar(200) NULL,
			measurement_event_id bigint NULL,
			meas_event_field_concept_id integer NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.OBSERVATION (
			observation_id bigint NOT NULL,
			person_id bigint NOT NULL,
			observation_concept_id integer NOT NULL,
			observation_date date NOT NULL,
			observation_datetime TIMESTAMP NULL,
			observation_type_concept_id integer NOT NULL,
			value_as_number NUMERIC NULL,
			value_as_string varchar(800) NULL,
			value_as_concept_id integer NULL,
			qualifier_concept_id integer NULL,
			unit_concept_id integer NULL,
			provider_id bigint NULL,
			visit_occurrence_id bigint NULL,
			visit_detail_id bigint NULL,
			observation_source_value varchar(250) NULL,
			observation_source_concept_id integer NULL,
			unit_source_value varchar(100) NULL,
			qualifier_source_value varchar(50) NULL,
			value_source_value varchar(100) NULL,
			observation_event_id integer NULL,
			obs_event_field_concept_id integer NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.DEATH (
			person_id bigint NOT NULL,
			death_date date NOT NULL,
			death_datetime TIMESTAMP NULL,
			death_type_concept_id integer NULL,
			cause_concept_id integer NULL,
			cause_source_value varchar(50) NULL,
			cause_source_concept_id integer NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.NOTE (
			note_id integer NOT NULL,
			person_id bigint NOT NULL,
			note_date date NOT NULL,
			note_datetime TIMESTAMP NULL,
			note_type_concept_id integer NOT NULL,
			note_class_concept_id integer NOT NULL,
			note_title varchar(250) NULL,
			note_text TEXT NOT NULL,
			encoding_concept_id integer NOT NULL,
			language_concept_id integer NOT NULL,
			provider_id bigint NULL,
			visit_occurrence_id bigint NULL,
			visit_detail_id bigint NULL,
			note_source_value varchar(50) NULL,
			note_event_id integer NULL,
			note_event_field_concept_id integer NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON RANDOM
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.NOTE_NLP (
			note_nlp_id integer NOT NULL,
			note_id integer NOT NULL,
			section_concept_id integer NULL,
			snippet varchar(250) NULL,
			"offset" varchar(50) NULL,
			lexical_variant varchar(250) NOT NULL,
			note_nlp_concept_id integer NULL,
			note_nlp_source_concept_id integer NULL,
			nlp_system varchar(250) NULL,
			nlp_date date NOT NULL,
			nlp_datetime TIMESTAMP NULL,
			term_exists varchar(1) NULL,
			term_temporal varchar(50) NULL,
			term_modifiers varchar(2000) NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.SPECIMEN (
			specimen_id integer NOT NULL,
			person_id bigint NOT NULL,
			specimen_concept_id integer NOT NULL,
			specimen_type_concept_id integer NOT NULL,
			specimen_date date NOT NULL,
			specimen_datetime TIMESTAMP NULL,
			quantity NUMERIC NULL,
			unit_concept_id integer NULL,
			anatomic_site_concept_id integer NULL,
			disease_status_concept_id integer NULL,
			specimen_source_id varchar(50) NULL,
			specimen_source_value varchar(50) NULL,
			unit_source_value varchar(50) NULL,
			anatomic_site_source_value varchar(50) NULL,
			disease_status_source_value varchar(50) NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON RANDOM
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.FACT_RELATIONSHIP (
			domain_concept_id_1 integer NOT NULL,
			fact_id_1 integer NOT NULL,
			domain_concept_id_2 integer NOT NULL,
			fact_id_2 integer NOT NULL,
			relationship_concept_id integer NOT NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON RANDOM
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.LOCATION (
			location_id bigint NOT NULL,
			address_1 varchar(50) NULL,
			address_2 varchar(50) NULL,
			city varchar(50) NULL,
			state varchar(2) NULL,
			zip varchar(9) NULL,
			county varchar(20) NULL,
			location_source_value varchar(50) NULL,
			country_concept_id integer NULL,
			country_source_value varchar(80) NULL,
			latitude NUMERIC NULL,
			longitude NUMERIC NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON RANDOM
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.CARE_SITE (
			care_site_id integer NOT NULL,
			care_site_name varchar(255) NULL,
			place_of_service_concept_id integer NULL,
			location_id bigint NULL,
			care_site_source_value varchar(50) NULL,
			place_of_service_source_value varchar(50) NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON RANDOM
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.PROVIDER (
			provider_id bigint NOT NULL,
			provider_name varchar(255) NULL,
			npi varchar(20) NULL,
			dea varchar(20) NULL,
			specialty_concept_id integer NULL,
			care_site_id integer NULL,
			year_of_birth integer NULL,
			gender_concept_id integer NULL,
			provider_source_value varchar(50) NULL,
			specialty_source_value varchar(250) NULL,
			specialty_source_concept_id integer NULL,
			gender_source_value varchar(50) NULL,
			gender_source_concept_id integer NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.PAYER_PLAN_PERIOD (
			payer_plan_period_id integer NOT NULL,
			person_id bigint NOT NULL,
			payer_plan_period_start_date date NOT NULL,
			payer_plan_period_end_date date NOT NULL,
			payer_concept_id integer NULL,
			payer_source_value varchar(50) NULL,
			payer_source_concept_id integer NULL,
			plan_concept_id integer NULL,
			plan_source_value varchar(50) NULL,
			plan_source_concept_id integer NULL,
			sponsor_concept_id integer NULL,
			sponsor_source_value varchar(50) NULL,
			sponsor_source_concept_id integer NULL,
			family_source_value varchar(50) NULL,
			stop_reason_concept_id integer NULL,
			stop_reason_source_value varchar(50) NULL,
			stop_reason_source_concept_id integer NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON RANDOM
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.COST (
			cost_id integer NOT NULL,
			cost_event_id integer NOT NULL,
			cost_domain_id varchar(20) NOT NULL,
			cost_type_concept_id integer NOT NULL,
			currency_concept_id integer NULL,
			total_charge NUMERIC NULL,
			total_cost NUMERIC NULL,
			total_paid NUMERIC NULL,
			paid_by_payer NUMERIC NULL,
			paid_by_patient NUMERIC NULL,
			paid_patient_copay NUMERIC NULL,
			paid_patient_coinsurance NUMERIC NULL,
			paid_patient_deductible NUMERIC NULL,
			paid_by_primary NUMERIC NULL,
			paid_ingredient_cost NUMERIC NULL,
			paid_dispensing_fee NUMERIC NULL,
			payer_plan_period_id integer NULL,
			amount_allowed NUMERIC NULL,
			revenue_code_concept_id integer NULL,
			revenue_code_source_value varchar(50) NULL,
			drg_concept_id integer NULL,
			drg_source_value varchar(3) NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.DRUG_ERA (
			drug_era_id bigint NOT NULL,
			person_id bigint NOT NULL,
			drug_concept_id integer NOT NULL,
			drug_era_start_date date NOT NULL,
			drug_era_end_date date NOT NULL,
			drug_exposure_count integer NULL,
			gap_days integer NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.DOSE_ERA (
			dose_era_id bigint NOT NULL,
			person_id bigint NOT NULL,
			drug_concept_id integer NOT NULL,
			unit_concept_id integer NOT NULL,
			dose_value NUMERIC NOT NULL,
			dose_era_start_date date NOT NULL,
			dose_era_end_date date NOT NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.CONDITION_ERA (
			condition_era_id bigint NOT NULL,
			person_id bigint NOT NULL,
			condition_concept_id integer NOT NULL,
			condition_era_start_date date NOT NULL,
			condition_era_end_date date NOT NULL,
			condition_occurrence_count integer NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON KEY (person_id)
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.EPISODE (
			episode_id integer NOT NULL,
			person_id bigint NOT NULL,
			episode_concept_id integer NOT NULL,
			episode_start_date date NOT NULL,
			episode_start_datetime TIMESTAMP NULL,
			episode_end_date date NULL,
			episode_end_datetime TIMESTAMP NULL,
			episode_parent_id integer NULL,
			episode_number integer NULL,
			episode_object_concept_id integer NOT NULL,
			episode_type_concept_id integer NOT NULL,
			episode_source_value varchar(50) NULL,
			episode_source_concept_id integer NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON RANDOM
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.EPISODE_EVENT (
			episode_id integer NOT NULL,
			event_id integer NOT NULL,
			episode_event_field_concept_id integer NOT NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON RANDOM
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.METADATA (
			metadata_id integer NOT NULL,
			metadata_concept_id integer NOT NULL,
			metadata_type_concept_id integer NOT NULL,
			name varchar(250) NOT NULL,
			value_as_string varchar(250) NULL,
			value_as_concept_id integer NULL,
			value_as_number NUMERIC NULL,
			metadata_date date NULL,
			metadata_datetime TIMESTAMP NULL )
			TABLESPACE pg_default;

--HINT DISTRIBUTE ON RANDOM
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.CDM_SOURCE (
			cdm_source_name varchar(255) NOT NULL,
			cdm_source_abbreviation varchar(25) NOT NULL,
			cdm_holder varchar(255) NOT NULL,
			source_description TEXT NULL,
			source_documentation_reference varchar(255) NULL,
			cdm_etl_reference varchar(255) NULL,
			source_release_date date NOT NULL,
			cdm_release_date date NOT NULL,
			cdm_version varchar(10) NULL,
			cdm_version_concept_id integer NOT NULL,
			vocabulary_version varchar(20) NOT NULL )
			TABLESPACE pg_default;
			
CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.stem_source
(
    domain_id character varying(20) COLLATE pg_catalog."default",
    person_id bigint,
    visit_occurrence_id bigint,
    visit_detail_id bigint,
    provider_id bigint,
    id bigint,
    concept_id integer,
    source_value character varying(500) COLLATE pg_catalog."default",
    source_concept_id integer,
    type_concept_id integer,
    start_date date,
    end_date date,
    start_time time(6) without time zone,
    days_supply integer,
    dose_unit_concept_id integer,
    dose_unit_source_value character varying(50) COLLATE pg_catalog."default",
    effective_drug_dose character varying(50) COLLATE pg_catalog."default",
    lot_number character varying(50) COLLATE pg_catalog."default",
    modifier_source_value character varying(50) COLLATE pg_catalog."default",
    operator_concept_id integer,
    qualifier_concept_id integer,
    qualifier_source_value character varying(50) COLLATE pg_catalog."default",
    quantity double precision,
    range_high double precision,
    range_low double precision,
    refills integer,
    route_concept_id integer,
    route_source_value character varying(100) COLLATE pg_catalog."default",
    sig character varying(255) COLLATE pg_catalog."default",
    stop_reason character varying(20) COLLATE pg_catalog."default",
    unique_device_id character varying(50) COLLATE pg_catalog."default",
    unit_concept_id integer,
    unit_source_value character varying(300) COLLATE pg_catalog."default",
	unit_source_concept_id integer,
    value_as_concept_id integer,
    value_as_number double precision,
    value_as_string character varying(800) COLLATE pg_catalog."default",
    value_source_value character varying(200) COLLATE pg_catalog."default",
    anatomic_site_concept_id integer,
    disease_status_concept_id integer,
    specimen_source_id character varying(50) COLLATE pg_catalog."default",
    anatomic_site_source_value character varying(50) COLLATE pg_catalog."default",
    disease_status_source_value character varying(50) COLLATE pg_catalog."default",
    modifier_concept_id integer,
	measurement_event_id bigint,
	meas_event_field_concept_id integer,
	observation_event_id bigint,
	obs_event_field_concept_id integer,
    stem_source_table character varying(255) COLLATE pg_catalog."default",
    stem_source_id character varying(255) COLLATE pg_catalog."default")
	TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {TARGET_SCHEMA}.stem
(
    domain_id character varying(20) COLLATE pg_catalog."default",
    person_id bigint,
    visit_occurrence_id bigint,
    visit_detail_id bigint,
    provider_id bigint,
    id bigint,
    concept_id integer,
    source_value character varying(250) COLLATE pg_catalog."default",
    source_concept_id integer,
    type_concept_id integer,
    start_date date,
    end_date date,
    start_time time(6) without time zone,
    days_supply integer,
    dose_unit_concept_id integer,
    dose_unit_source_value character varying(50) COLLATE pg_catalog."default",
    effective_drug_dose character varying(50) COLLATE pg_catalog."default",
    lot_number character varying(50) COLLATE pg_catalog."default",
    modifier_source_value character varying(50) COLLATE pg_catalog."default",
    operator_concept_id integer,
    qualifier_concept_id integer,
    qualifier_source_value character varying(50) COLLATE pg_catalog."default",
    quantity double precision,
    range_high double precision,
    range_low double precision,
    refills integer,
    route_concept_id integer,
    route_source_value character varying(100) COLLATE pg_catalog."default",
    sig character varying(255) COLLATE pg_catalog."default",
    stop_reason character varying(20) COLLATE pg_catalog."default",
    unique_device_id character varying(50) COLLATE pg_catalog."default",
    unit_concept_id integer,
    unit_source_value character varying(250) COLLATE pg_catalog."default",
	unit_source_concept_id integer,
    value_as_concept_id integer,
    value_as_number double precision,
    value_as_string character varying(800) COLLATE pg_catalog."default",
    value_source_value character varying(200) COLLATE pg_catalog."default",
    anatomic_site_concept_id integer,
    disease_status_concept_id integer,
    specimen_source_id character varying(50) COLLATE pg_catalog."default",
    anatomic_site_source_value character varying(50) COLLATE pg_catalog."default",
    disease_status_source_value character varying(50) COLLATE pg_catalog."default",
    modifier_concept_id integer,
	measurement_event_id bigint,
	meas_event_field_concept_id integer,
	observation_event_id bigint,
	obs_event_field_concept_id integer,
    stem_source_table character varying(255) COLLATE pg_catalog."default",
    stem_source_id character varying(255) COLLATE pg_catalog."default")
	TABLESPACE pg_default;

--HINT DISTRIBUTE ON RANDOM
--CREATE TABLE IF NOT EXISTS results.COHORT ( -- CREATED LATER BY ATLAS SCRIPT
--			cohort_definition_id integer NOT NULL,
--			subject_id integer NOT NULL,
--			cohort_start_date date NOT NULL,
--			cohort_end_date date NOT NULL )
--			TABLESPACE tablespace_e;
--
----HINT DISTRIBUTE ON RANDOM
--CREATE TABLE IF NOT EXISTS results.COHORT_DEFINITION ( -- CREATED LATER BY ATLAS SCRIPT
--			cohort_definition_id integer NOT NULL,
--			cohort_definition_name varchar(255) NOT NULL,
--			cohort_definition_description TEXT NULL,
--			definition_type_concept_id integer NOT NULL,
--			cohort_definition_syntax TEXT NULL,
--			subject_concept_id integer NOT NULL,
--			cohort_initiation_date date NULL )
--			TABLESPACE tablespace_e;
