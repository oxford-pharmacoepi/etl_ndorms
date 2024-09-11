-- insert death_ons to death
With cte as(
	insert into {TARGET_SCHEMA_TO_LINK}.death
	select t1.* 
	from {TARGET_SCHEMA}.death_ons as t1
	left join {TARGET_SCHEMA_TO_LINK}.death as t2 on t1.person_id = t2.person_id
	where t2.person_id is null
	returning *
)
select count(*) from cte; --return no.of rows insert into {TARGET_SCHEMA_TO_LINK}.death