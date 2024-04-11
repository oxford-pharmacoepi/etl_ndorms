With stcm AS(
	select * from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as stcm
	where source_vocabulary_id = 'ONS_DEATH_CAUSE_STCM'
),icd10_1 AS(
	select source_code, source_concept_id
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map
	where source_vocabulary_id = 'ICD10'
	group by source_code, source_concept_id
	having count(*) =1
), icd9_1 AS(
	select t1.source_code, t1.source_concept_id
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t1
	left join icd10_1 as t2 on t1.source_code = t2.source_code
	where t2.source_code is null 
	and t1.source_vocabulary_id = 'ICD9CM'
	group by t1.source_code, t1.source_concept_id
	having count(*) =1
), dc_vocab as(
	select ss.source_code, ss.source_concept_id, ss.target_concept_id from icd10_1
	left join stcm on stcm.source_code = icd10_1.source_code 
	join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map ss on icd10_1.source_concept_id = ss.source_concept_id
	where stcm.source_code is null
	
	union
	
	select ss.source_code, ss.source_concept_id, ss.target_concept_id from icd9_1
	left join stcm on stcm.source_code = icd9_1.source_code 
	join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map ss on icd9_1.source_concept_id = ss.source_concept_id
	where stcm.source_code is null
	
	union
	
	select source_code, source_concept_id, target_concept_id from stcm
)
INSERT INTO {TARGET_SCHEMA}.death_ons
SELECT patid,
	dod,
	dod, 
	32815,
	COALESCE(t2.target_concept_id, t3.target_concept_id, 0),
	CASE 
		WHEN COALESCE(t2.target_concept_id, t3.target_concept_id, 0) =0 AND COALESCE(t2.source_concept_id, 0) = 0 THEN null
		ELSE cause
	END AS cause,
	CASE 
		WHEN COALESCE(t2.target_concept_id, t3.target_concept_id, 0) =0 AND COALESCE(t2.source_concept_id, 0) = 0 THEN null
		ELSE COALESCE(t2.source_concept_id, 0)
	END AS casue_source_concept_id
FROM {SOURCE_SCHEMA}.ons_death as t1
left join dc_vocab as t2 on t1.cause = t2.source_code
left join dc_vocab as t3 on substring(t1.cause from 0 for 4) = t3.source_code and t2.source_code is null;


-- added PK in death_ons
ALTER TABLE {TARGET_SCHEMA}.death_ons ADD CONSTRAINT xpk_death_ons PRIMARY KEY (person_id) USING INDEX TABLESPACE pg_default;