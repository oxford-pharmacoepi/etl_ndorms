-- insert death_ons to death
With cte as(
	insert into {TARGET_SCHEMA_TO_LINK}.death
	select t1.* 
	from {TARGET_SCHEMA}.death_ons as t1
	inner join {TARGET_SCHEMA_TO_LINK}.person as t2 on t1.person_id = t2.person_id
	left join {TARGET_SCHEMA_TO_LINK}.death as t3 on t1.person_id = t3.person_id
	where t3.person_id is null
	returning *
)
select count(*) from cte; --return no.of rows insert into {TARGET_SCHEMA_TO_LINK}.death