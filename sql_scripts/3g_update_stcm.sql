update {VOCABULARY_SCHEMA}.source_to_concept_map
set target_concept_id = %s,
target_vocabulary_id = %s,
valid_start_date = %s,
valid_end_date = %s
where source_vocabulary_id = %s and source_code = %s;

Update {VOCABULARY_SCHEMA}.source_to_source_vocab_map ss
set target_concept_id = c.concept_id,
target_concept_name = c.concept_name,
target_vocabulary_id = c.vocabulary_id,
target_domain_id = c.domain_id,
target_concept_class_id = c.concept_class_id,
target_invalid_reason = c.invalid_reason,
target_standard_concept = c.standard_concept
from {VOCABULARY_SCHEMA}.source_to_concept_map sc 
join {VOCABULARY_SCHEMA}.concept c on c.concept_id = sc.target_concept_id
where ss.source_code = sc.source_code and ss.source_vocabulary_id = sc.source_vocabulary_id
and ss.source_vocabulary_id = %s and ss.source_code = %s;

Update {VOCABULARY_SCHEMA}.source_to_standard_vocab_map ss
set target_concept_id = c.concept_id,
target_concept_name = c.concept_name,
target_vocabulary_id = c.vocabulary_id,
target_domain_id = c.domain_id,
target_concept_class_id = c.concept_class_id,
target_invalid_reason = c.invalid_reason,
target_standard_concept = c.standard_concept
from {VOCABULARY_SCHEMA}.source_to_concept_map sc 
join {VOCABULARY_SCHEMA}.concept c on c.concept_id = sc.target_concept_id
where ss.source_code = sc.source_code and ss.source_vocabulary_id = sc.source_vocabulary_id
and ss.source_vocabulary_id = %s and ss.source_code = %s;