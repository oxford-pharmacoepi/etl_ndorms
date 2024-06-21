With to_delete AS(
	select * from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map 
	where source_vocabulary_id = %s
	and (target_invalid_reason is not null or target_standard_concept is null)
)
delete from {VOCABULARY_SCHEMA}.source_to_concept_map as t1 
using to_delete as t2
WHERE t1.source_code = t2.source_code and t1.source_vocabulary_id = t2.source_vocabulary_id
and t1.target_concept_id = t2.target_concept_id;