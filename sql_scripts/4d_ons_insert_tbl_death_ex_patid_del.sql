-- insert death_ons to death
insert into {TARGET_SCHEMA_TO_LINK}.death
select t1.*  
from {TARGET_SCHEMA}.death_ons as t1
left join {TARGET_SCHEMA_TO_LINK}.death as t2 on t1.person_id = t2.person_id 
left join {TARGET_SCHEMA_TO_LINK}._patid_deleted as t3 on t1.person_id = t3.patid
where t2.person_id is null and t3.patid is null;
