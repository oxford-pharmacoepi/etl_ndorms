ALTER TABLE {SOURCE_SCHEMA}.staff ADD CONSTRAINT pk_staff PRIMARY KEY(staffid, role);

CREATE INDEX IF NOT EXISTS idx_staff_role ON {SOURCE_SCHEMA}.staff (role);
--TO WE NEED THIS AND THE FIRST ON ROLE??
-- [Teen] yes, we need it. 
-- During mapping, staff join to lookup on role 
-- {AD} Why the PK is not sufficient? Should we remove role from there?
-- [Teen] because Staff join to lookup using role only. The SQL is as follows.
/*
select
	  staffid as PROVIDER_ID,
	  MOD(staffid, 100000)  as CARE_SITE_ID,
	  cast(staffid as varchar) as PROVIDER_SOURCE_VALUE,
	  l.text as SPECIALTY_SOURCE_VALUE,
	  cast(coalesce(role, 0) as varchar) as SPECIALTY_SOURCE_KEY,
	  case
	      when gender = 1 then 'M'
	      when gender = 2 then 'F'
	      else null
	  end as gender,
	  case
	      when coalesce(gender, 0) = 1 then 8507
	      when coalesce(gender, 0) = 2 then 8532
	      else 0
	  end as gender_concept_id
	  from {sc}.Staff s
	  JOIN {sc}.lookup l ON s.role = l.code
	  where lookup_type_id = 76
*/