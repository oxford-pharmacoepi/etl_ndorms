-- update observation_period from updated_death
With temp1 AS(
	select t1.observation_period_id, t2.death_date
	from {TARGET_SCHEMA_TO_LINK}.observation_period as t1
	join {TARGET_SCHEMA_TO_LINK}.death as t2 on t1.person_id = t2.person_id
), cte as(
	update {TARGET_SCHEMA_TO_LINK}.observation_period as t1
	SET observation_period_end_date = t2.death_date
	from temp1 as t2 
	where t1.observation_period_id = t2.observation_period_id
	and t1.observation_period_end_date > t2.death_date
	returning t1.*
)
select count(*) from cte;