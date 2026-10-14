--------------Creating tumour Table ---------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.tumour (
	patid						bigint,
	cr_patid					varchar(25),
	cr_id						varchar(25),
	ethnicity					varchar(10),
	ethnicityname				varchar(35),
	diagnosisdatebest			date,	
	diagnosisdateflag			smallint,
	basisofdiagnosis			varchar(1),
	site_icd10_o2				varchar(5),
	site_icd10_o2_3char			varchar(5),
	morph_icd10_o2				int,
	behaviour_icd10_o2			varchar(20),
	site_coded					varchar(6),
	site_coded_desc				varchar(100),
	site_coded_3char			varchar(5),
	coding_system				smallint,
	coding_system_desc			varchar(20),	
	morph_coded					varchar(10),
	behaviour_coded				varchar(5), --- This attribute has a Field type of NUMBER in the Cancer Registration Data Dictionary, but I have set it as VARCHAR because one of the record value = 'X' for Unknown / Inapplicable entries.
	behaviour_coded_desc		varchar(60),	
	histology_coded				varchar(10),
	histology_coded_desc		varchar(200),
	grade						varchar(5),
	tumoursize					NUMERIC,
	nodesexcised				int,
	nodesinvolved				int,
	tumourcount					int,
	bigtumourcount				int,
	route_code					varchar(10),
	final_route					varchar(25),
	stage_best					varchar(10),
	t_best						varchar(10),
	n_best						varchar(10),
	m_best						varchar(10),
	stage_best_system			varchar(10),
	t_img						varchar(5),
	n_img						varchar(5),
	m_img						varchar(5),
	stage_img					varchar(5),
	stage_img_system			smallint,
	t_path						varchar(10),
	n_path						varchar(5),
	m_path						varchar(5),
	stage_path					varchar(5),
	stage_path_system			smallint,
	stage_path_pretreated		varchar(5),
	chrl_tot_27_03				int,
	chrl_tot_78_06				int,
	er_status					varchar(2),
	er_score					int,
	pr_status					varchar(2),
	pr_score					int,
	her2_status					varchar(2),
	npi							NUMERIC,
	dukes						varchar(2),
	figo						varchar(5),
	gleason_primary				smallint,
	gleason_secondary			smallint,
	gleason_tertiary			smallint,
	gleason_combined			smallint,
	screendetected				varchar(1),
	screeningstatuscosd_code	varchar(2),
	screeningstatuscosd_name	varchar(20),
	screeningstatusfull_code	varchar(35),
	screeningstatusfull_name	varchar(120),
	laterality					varchar(1),
	dco							varchar(5),
	vitalstatus					varchar(15),
	vitalstatusdate				date,
	first_hosp_date				date,
	multifocal					varchar(1),
	clarks						int,
	breslow						varchar(10),
	excisionmargin				varchar(2)
)
TABLESPACE pg_default;

--------------Creating treatment Table ---------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.treatment (
	treatment_id			bigserial,		--to allow for a PK
	patid					bigint,
	cr_patid				varchar(25),
	cr_id					varchar(25),
	number_of_tumours		int,
	eventcode				varchar(5),
	eventdesc				varchar(40),
	eventdate				date,
	within_six_months_flag	smallint,
	six_months_after_flag	smallint,
	opcs4_code				varchar(10),
	opcs4_name				varchar(150),
	radiocode				varchar(5),
	radiodesc				varchar(30),
	imagingcode				varchar(5),
	imagingdesc				varchar(35),
	imagingsite				varchar(5),
	lesionsize				NUMERIC,
	chemo_all_drug			varchar(100),
	chemo_drug_group		varchar(50)
)
TABLESPACE pg_default;

--------------Creating RTDS Tables ---------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.rtds_episode (
	patid								bigint,
	pracid								int,
	attendid							bigint,
	apptdate							date,
	appt_mm								smallint,
	appt_yyyy							smallint,
	decisiontotreatdate					date,
	dttd_mm								smallint,
	dttd_yyyy							smallint,
	earliestclinappropriatedate			date,
	earliestclinappropriatedate_mm		smallint,
	earliestclinappropriatedate_yyyy	smallint,
	radiotherapypriority				varchar(13),		--it should be 1, lots of rubbish
	treatmentstartdate					date,
	rtsd_mm								smallint,
	rtsd_yyyy							smallint,
	radiotherapydiagnosisicd			varchar(7),
	radiotherapyintent					varchar(2),
	source								varchar(7)
)
TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.rtds_prescription (
	patid						bigint,
	pracid						int,
	prescriptionid				bigint,
	rttreatmentregion			varchar(4),
	rttreatmentanatomicalsite	varchar(32), -- should be 4, there is some rubbish in the data
	numberofteletherapyfields	smallint,
	rtprescribeddose			double precision,
	prescribedfractions			smallint,
	rtactualdose				double precision,
	rtactualfractions			smallint,
	rttreatmentmodality			varchar(2)
)
TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.rtds_exposures (
	patid						bigint,
	pracid						int,
	attendid					bigint,
	machineid					bigint,
	radioisotope				varchar(29), --It should be 6, full of rubbish
	radiotherapybeamtype		varchar(2),
	radiotherapybeamenergy		double precision,
	timeofexposure				time
)
TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.rtds_opcds (
	patid						bigint,
	pracid						int,
	attendid					bigint,
	primaryprocedureopcs		varchar(19),
	proceduredate				date,
	procedure_mm				smallint,
	procedure_yyyy				smallint
)
TABLESPACE pg_default;
	
--------------Creating SACT Table ---------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.sact (
	patid								bigint,
	pracid								int,
	consultant_speciality_code			varchar(8),
	primary_diagnosis					varchar(7),
	intent_of_treatment_v2				varchar(2),
	intent_of_treatment_v3				varchar(14),
	adjunctive_therapy					smallint,
	analysis_group						varchar(256),
	benchmark_group						varchar(256),
	height_at_start_of_regimen			double precision,
	weight_at_start_of_regimen			double precision,
	perf_stat_start_of_reg_adult		varchar(2),
	comorbidity_adjustment				varchar(1),
	date_decision_to_treat				date,
	start_date_of_regimen				date,
	clinical_trial						varchar(2),
	cycle_number						smallint,
	start_date_of_cycle					date,
	weight_at_start_of_cycle			double precision,
	perf_stat_start_of_cycle_adult		varchar(2),
	drug_group							varchar(35),
	actual_dose_per_administration		double precision,
	admin_measure_per_actual_dose		varchar(2),
	administration_route				varchar(2),
	administration_date					date,
	regimen_modified_dose_reduction		varchar(1),
	regiment_modified_time_delay		varchar(1),
	regiment_modified_stopped_early		varchar(1),
	regimen_outcome_summary				varchar(1),
	regoutsum_curative_not_completed	varchar(3),
	regoutsum_non_curative				varchar(1),
	regoutsum_toxic						varchar(1),
	regoutsum_curative_completed_as_	varchar(1),
	sact_dataset						varchar(7)
)
TABLESPACE pg_default;
