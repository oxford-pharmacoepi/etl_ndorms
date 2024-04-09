With icd10_temp AS(
	select source_concept_id
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map
	where source_vocabulary_id = 'ICD10'
	and target_standard_concept = 'S' 
	and target_invalid_reason is null
	group by source_concept_id
	having count(*) =1
), dc_vocab as(
	select t1.source_code, t1.source_concept_id, t1.target_concept_id
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t1 
	join icd10_temp as t2 on t1.source_concept_id = t2.source_concept_id

	UNION

	select source_code, source_concept_id, target_concept_id
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map  
	where source_vocabulary_id = 'ONS_DEATH_CAUSE_STCM'
)
INSERT INTO {TARGET_SCHEMA}.death_ons
SELECT patid,
	dod,
	dod, 
	32815,
	COALESCE(target_concept_id, 0),
	cause,
	COALESCE(source_concept_id, 0)
FROM {SOURCE_SCHEMA}.ons_death as t1
left join dc_vocab as t2 on t1.cause = t2.source_code;


-- added PK in death_ons
ALTER TABLE {TARGET_SCHEMA}.death_ons ADD CONSTRAINT xpk_death_ons PRIMARY KEY (person_id) USING INDEX TABLESPACE pg_default;