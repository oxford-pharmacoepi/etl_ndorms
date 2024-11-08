DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.tumour CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.treatment CASCADE;

CREATE TABLE {SOURCE_NOK_SCHEMA}.tumour (LIKE {SOURCE_SCHEMA}.tumour) TABLESPACE pg_default;
CREATE TABLE {SOURCE_NOK_SCHEMA}.treatment (LIKE {SOURCE_SCHEMA}.treatment) TABLESPACE pg_default;

-- tumour
INSERT INTO {SOURCE_NOK_SCHEMA}.tumour(
	select t1.* 
	from {SOURCE_SCHEMA}.tumour as t1
	left join {TARGET_SCHEMA_TO_LINK}.person as t2 on t1.e_patid = t2.person_id
	where t2.person_id is null													-- Eliminated by patients not exist in {target_to_link}.person

	UNION

	select t1.* 
	from {SOURCE_SCHEMA}.tumour as t1
	join {SOURCE_SCHEMA}.linkage_coverage as t2 on t2.data_source = 'ncras_cr'	
	where t1.diagnosisdatebest < t2.start or t1.diagnosisdatebest > t2.end		-- Eliminate tumour out of linkage_coverage period
);

alter table {SOURCE_NOK_SCHEMA}.tumour add constraint pk_tumour_nok primary key (e_patid,e_cr_patid,e_cr_id) USING INDEX TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.tumour as t1 
using {SOURCE_NOK_SCHEMA}.tumour as t2
WHERE t1.e_patid = t2.e_patid
and t1.e_cr_patid = t2.e_cr_patid
and t1.e_cr_id = t2.e_cr_id;

-- treatment
With cte as(																
	select			
		e_patid,					
		e_cr_id,					
		e_cr_patid,				
		number_of_tumours,		
		eventcode,				
		eventdesc,				
		eventdate,				
		within_six_months_flag,	
		six_months_after_flag,	
		opcs4_code,				
		opcs4_name,				
		radiocode,				
		radiodesc,				
		lesionsize,				
		chemo_all_drug,			
		chemo_drug_group, 
		min(treatment_id) as min_treatment_id
	from {SOURCE_SCHEMA}.treatment
	group by 	e_patid, e_cr_id, e_cr_patid, number_of_tumours,		
				eventcode, eventdesc, eventdate,				
				within_six_months_flag,	six_months_after_flag, 
				opcs4_code, opcs4_name, 
				radiocode, radiodesc, lesionsize, 
				chemo_all_drug, chemo_drug_group
)
INSERT INTO {SOURCE_NOK_SCHEMA}.treatment(
	select t1.* 
	from {SOURCE_SCHEMA}.treatment as t1
	left join {TARGET_SCHEMA_TO_LINK}.person as t2 on t1.e_patid = t2.person_id
	where t2.person_id is null													-- Eliminated by patients not exist in {target_to_link}.person

	UNION

	select t1.* 
	from {SOURCE_SCHEMA}.treatment as t1
	join {SOURCE_SCHEMA}.linkage_coverage as t2 on t2.data_source = 'ncras_cr'
	where t1.eventdate < t2.start or t1.eventdate > t2.end						-- Eliminate treatment out of linkage_coverage period
	
	UNION
	
	select * from {SOURCE_SCHEMA}.treatment
	where eventdate is null														-- Eliminate treatment without eventdate
	
	UNION
	
	select t1.*																	-- Eliminate duplication
	from {SOURCE_SCHEMA}.treatment as t1
	left join cte as t2 on t1.treatment_id = t2.min_treatment_id
	where t2.min_treatment_id is null
);

alter table {SOURCE_NOK_SCHEMA}.treatment add constraint pk_treatment_nok primary key (treatment_id) USING INDEX TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.treatment as t1 
using {SOURCE_NOK_SCHEMA}.treatment as t2
WHERE t1.treatment_id = t2.treatment_id;