--------------Creating tumour Table ---------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.tumour (
	e_patid					bigint,
	e_cr_patid				bigint,
	e_cr_id					bigint,
	ethnicity				varchar(10),
	ethnicityname			varchar(35),
	diagnosisdatebest		date,	
	diagnosisdateflag		smallint,
	basisofdiagnosis		smallint,
	site_icd10_o2			varchar(5),
	site_icd10_o2_3char		varchar(5),
	morph_icd10_o2			int,
	behaviour_icd10_o2		varchar(20),
	site_coded_3char		varchar(5),
	coding_system			smallint,
	coding_system_desc		varchar(20),	
	morph_coded				varchar(10),
	behaviour_coded			varchar(5), --- This attribute has a Field type of NUMBER in the Cancer Registration Data Dictionary, but I have set it as VARCHAR because one of the record value = 'X' for Unknown / Inapplicable entries.
	behaviour_coded_desc	varchar(60),	
	histology_coded			varchar(10),
	histology_coded_desc	varchar(70),
	grade					varchar(5),
	tumoursize				NUMERIC,
	nodesexcised			int,
	nodesinvolved			int,
	tumourcount				int,
	bigtumourcount			int,
	stage_best				varchar(10),
	t_best					varchar(10),
	n_best					varchar(10),
	m_best					varchar(10),
	stage_best_system		varchar(10),
	t_img					varchar(5),
	n_img					varchar(5),
	m_img					varchar(5),
	stage_img				varchar(5),
	stage_img_system		smallint,
	t_path					varchar(5),
	n_path					varchar(5),
	m_path					varchar(5),
	stage_path				varchar(5),
	stage_path_system		smallint,
	stage_path_pretreated	varchar(5),
	chrl_tot_27_03			int,
	chrl_tot_78_06			int,
	gleason_primary			smallint,
	gleason_secondary		smallint,
	gleason_tertiary		smallint,
	gleason_combined		smallint,
	dco						varchar(5),
	vitalstatus				varchar(15),
	vitalstatusdate			date)
	TABLESPACE pg_default;
	
--------------Creating treatment Table ---------------------------------------
CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.treatment (
	e_patid					bigint,
	e_cr_id					bigint,
	e_cr_patid				bigint,
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
	lesionsize				NUMERIC,
	chemo_all_drug			varchar(50),
	chemo_drug_group		varchar(50))
	TABLESPACE pg_default;