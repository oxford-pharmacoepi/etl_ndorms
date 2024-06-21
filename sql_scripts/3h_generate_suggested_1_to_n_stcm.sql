select * from {VOCABULARY_SCHEMA}.temp_stcm
where source_vocabulary_id =%s
order by source_code;

With base AS(
	select * 
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map AS ss
	where ss.source_vocabulary_id =%s
	and (ss.target_standard_concept is null or ss.target_invalid_reason is not null)
)
select distinct sc.*
from base AS b
left join {VOCABULARY_SCHEMA}.temp_stcm on temp_stcm.source_code = b.source_code and temp_stcm.source_vocabulary_id = b.source_vocabulary_id
join {VOCABULARY_SCHEMA}.source_to_concept_map sc on sc.source_code = b.source_code and sc.source_vocabulary_id = b.source_vocabulary_id
where temp_stcm.source_code is null;