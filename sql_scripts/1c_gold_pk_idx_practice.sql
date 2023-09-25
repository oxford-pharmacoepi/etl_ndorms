ALTER TABLE {SOURCE_SCHEMA}.practice ADD CONSTRAINT pk_practice PRIMARY KEY(pracid, region);
--[AD] Is region useful as 2nd column in the PK?
-- [Teen] Yes, you're correct. pracid as PK is enough

--[AD] Would it be better to have the uts instead for a faster data cleaning?
-- [Teen] I don't know if index of uts could speed up the data cleanning for the condition, (deathdate is not null AND deathdate < (case when patient.frd > uts then patient.frd else b.uts end)
-- if yes, I agree to add an additional index on uts