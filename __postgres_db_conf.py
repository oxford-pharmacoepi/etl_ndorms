db_conf = dict({
	'username': 'user',
	'password': 'pwd',
	'database': 'database_name',
	'data_provider': 'name_of_provider',	#e.g. 'cprd', 'thin', 'ukb'('ukbiobank' for the exisiting mapped one)
	'database_type': 'type of database',	#e.g. 'gold, 'aurum', 'hesapc', 'ukb'(baseline), 'ukb_gp', 'ukb_hesin'
	'source_release_date': 'date',			#e.g. '2022-05-01'
	'cdm_version': '5.4',					#e.g. '5.3', '5.4'
	'cdm_etl_reference': 'name of developer',
	'datestyle': 'ISO,DMY',
	'source_schema': 'source',
	'source_nok_schema': 'source_nok',
	'linkage_schema': 'linkage',
	'target_schema': 'public',
	'vocabulary_schema': 'public',			#e.g. 'public', 'vocabulary'
	'target_schema_to_link': 'schema to which we want to link the data. If no link is required, it MUST be equal to target_schema',	#e.g. 'public_aurum'
	'chunk_schema': 'chunk_schema_name',
	'max_workers' : 5,
	'chunk_size': 1000,
	'chunk_limit': 0,
	'dir_processed': '/processed/',
#	'dir_study': '<project_directory>/',
	'dir_log': '<project_directory>/log',
	'dir_stcm': '<project_directory>/source_to_concept_map',
	'dir_source_data': '<project_directory>/data',
	'dir_lookup': '<project_directory>/lookups',
	'dir_voc': '<project_directory>/vocabulary', #Do not change below here
	'tbl_gold': ['additional', 'clinical', 'consultation', 'immunisation', 'patient', 'practice', 'referral', 'staff', 'test', 'therapy'],
	'tbl_gold_lookup':['bnfcodes', 'common_dosages', 'entity', 'medical', 'packtype', 'product', 'scoremethod', 'txtfiles\\*.txt'],
	'tbl_aurum' : ['practice', 'staff', 'patient', 'consultation', 'observation', 'problem', 'referral', 'drugissue'],
	'tbl_aurum_lookup': ['gender', 'region', 'jobcat', 'numunit', 'quantunit', 'refservicetype', 'medicaldictionary', 'productdictionary', 'visiontoemismigrators'],
	'tbl_aurum_denom': ['aurum_acceptablepats', 'aurum_practices'],
	'tbl_linkage_lookup': ['linkage_coverage'],
	'tbl_hesapc': ['hes_patient', 'hes_hospital', 'hes_acp', 'hes_ccare', 'hes_maternity', 'hes_episodes', 'hes_diagnosis_hosp', 'hes_primary_diag_hosp', 'hes_diagnosis_epi', 'hes_procedures_epi', 'hes_hrg'],
	'tbl_hesop': ['hesop_patient', 'hesop_appointment', 'hesop_clinical'],
	'tbl_hesae': ['hesae_patient', 'hesae_attendance', 'hesae_diagnosis', 'hesae_investigation', 'hesae_treatment', 'hesae_hrg', 'hesae_pathway'],
	'tbl_ons': ['linkage_coverage','ons_death'],
	'tbl_ncrascr': ['tumour', 'treatment'],
	'tbl_ukb_gp_lookup': ['lookup626', 'gold_product' , 'gold_daysupply_decodes', 'gold_daysupply_modes'],
	'tbl_ukb_cancer_lookup': ['lookup1970'],
	'tbl_ukb_baseline': ['baseline', 'death', 'death_cause'],
	'tbl_ukb_cancer': ['baseline', 'death', 'cancer'],
	'tbl_ukb_gp': ['baseline', 'death', 'gp_clinical', 'gp_registrations', 'gp_scripts'],
	'tbl_ukb_hesin': ['baseline', 'death', 'hesin', 'hesin_critical', 'hesin_delivery', 'hesin_diag', 'hesin_maternity', 'hesin_oper', 'hesin_psych'],
	'tbl_cprd': ['denominators', 'documentation', 'lookups', 'reference'],
	'tbl_cdm': ['care_site', 'condition_era', 'condition_occurrence', 'death', 'device_exposure', 'dose_era', 'drug_era', 'drug_exposure', 'location', 'measurement', 'observation', 'observation_period', 'person', 'procedure_occurrence', 'provider', 'specimen', 'visit_detail', 'visit_occurrence'],
	'tbl_cdm_voc': ['drug_strength', 'concept', 'concept_relationship', 'concept_ancestor', 'concept_synonym', 'vocabulary', 'relationship', 'concept_class', 'domain']
})
