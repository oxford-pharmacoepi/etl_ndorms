With tmp AS(
	select source_code, source_vocabulary_id
	from {VOCABULARY_SCHEMA}.temp_stcm
	where source_vocabulary_id =%s
	group by source_code, source_vocabulary_id
	having count(*) = 1
)
select t1.* 
from {VOCABULARY_SCHEMA}.temp_stcm as t1
join tmp as t2 on t1.source_code = t2.source_code 
where t1.source_vocabulary_id =%s
order by t1.source_code;

With base AS(
	select * 
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map AS ss
	where ss.source_vocabulary_id =%s
	and (ss.target_standard_concept is null or ss.target_invalid_reason is not null)
),tmp AS(
	select source_code, source_vocabulary_id
	from {VOCABULARY_SCHEMA}.temp_stcm
	where source_vocabulary_id =%s
	group by source_code, source_vocabulary_id
	having count(*) = 1
), to_insert AS(
	select t1.* 
	from {VOCABULARY_SCHEMA}.temp_stcm as t1
	join tmp as t2 on t1.source_code = t2.source_code 
	and t1.source_vocabulary_id = t2.source_vocabulary_id
)
select distinct sc.*
from base AS b
left join to_insert as i on i.source_code = b.source_code and i.source_vocabulary_id = b.source_vocabulary_id
join {VOCABULARY_SCHEMA}.source_to_concept_map sc on sc.source_code = b.source_code and sc.source_vocabulary_id = b.source_vocabulary_id
where i.source_code is null
order by sc.source_code;