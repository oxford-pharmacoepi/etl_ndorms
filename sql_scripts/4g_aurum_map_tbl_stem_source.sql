--insert into temp table from observation
CREATE TABLE {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (LIKE {TARGET_SCHEMA}.STEM_SOURCE);

WITH cte0 as (
		select person_id
		from {CHUNK_SCHEMA}.chunk_person
		where chunk_id = {CHUNK_ID}
	),
	t1 as (
		select o.patid as person_id, o.staffid as provider_id, o.obsid, o.obsdate as start_date, 
		case when p.probenddate is null
			then o.obsdate
			else p.probenddate
		end as end_date,
		o.medcodeid, o.value, o.numunitid, o.numrangehigh, o.numrangelow
		from cte0
		inner join {SOURCE_SCHEMA}.observation o on cte0.person_id = o.patid
		left join {SOURCE_SCHEMA}.problem p on o.obsid = p.obsid
	),
	t2 as (
		SELECT t1.*, n.description as unit_source_value,
		case when m.cleansedreadcode is null
			then concat(m.snomedctconceptid,'-',m.term)
			else concat(m.cleansedreadcode,'-',m.term)
		end as source_value,
		case when m.cleansedreadcode is null
			then t.SNOMED_source_concept_id
			else t.Read_source_concept_id
		end as source_concept_id
		FROM t1
		left join {SOURCE_SCHEMA}.numunit n on t1.numunitid = n.numunitid
		left join {SOURCE_SCHEMA}.medicaldictionary m on t1.medcodeid = m.medcodeid
		left join {SOURCE_SCHEMA}.temp_concept_map t on t1.medcodeid = t.medcodeid
	)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (domain_id, person_id, visit_occurrence_id, visit_detail_id, provider_id, concept_id, source_value,
					 source_concept_id, type_concept_id, start_date, end_date, start_time, days_supply, dose_unit_concept_id,
					 dose_unit_source_value, effective_drug_dose, lot_number, modifier_source_value, 
					 operator_concept_id, qualifier_concept_id, qualifier_source_value, quantity, 
					 range_high, range_low, refills, route_concept_id, route_source_value, sig, stop_reason, unique_device_id, unit_concept_id,
					 unit_source_value, value_as_concept_id, value_as_number, value_as_string,
					 value_source_value, anatomic_site_concept_id, disease_status_concept_id, specimen_source_id, anatomic_site_source_value, disease_status_source_value, 
					 modifier_concept_id, stem_source_table, stem_source_id)
select NULL as domain_id,
	t2.person_id, 
	vd.visit_occurrence_id,
	v.visit_detail_id,
	t2.provider_id,
	NULL as concept_id,
	t2.source_value,
	t2.source_concept_id,
	32817 as type_concept_id,
	t2.start_date,
	t2.end_date,
	'00:00:00'::time start_time,
	NULL as days_supply,
	0 as dose_unit_concept_id,
	NULL as dose_unit_source_value, 
	NULL as effective_drug_dose, 
	NULL as lot_number, 
	NULL as modifier_source_value,
	0 as operator_concept_id,
	0 as qualifier_concept_id,
	NULL as qualifier_source_value, 
	NULL as quantity, 
	t2.numrangehigh::double precision range_high,
	t2.numrangelow::double precision range_low,
	NULL as refills,
	0 as route_concept_id,
	NULL as route_source_value,
	0 as unit_concept_id,
	NULL as sig, 
	NULL as stop_reason, 
	NULL as unique_device_id,
	t2.unit_source_value,
	0 as value_as_concept_id,
	t2.value value_as_number,
	NULL as value_as_string,
	t2.value::varchar value_source_value,
	0 as anatomic_site_concept_id,
	0 as disease_status_concept_id,
	NULL as specimen_source_id,
	NULL as anatomic_site_source_value, 
	NULL as disease_status_source_value, 
	0 as modifier_concept_id,
	'Observation' stem_source_table,
	t2.obsid as stem_source_id
from t2
inner join {SOURCE_SCHEMA}.temp_visit_detail v on t2.obsid = v.visit_detail_source_id
inner join {TARGET_SCHEMA}.visit_detail vd on v.visit_detail_id = vd.visit_detail_id
WHERE v.source_table = 'Observation';


--insert into stem_source from consultation
WITH cte1 as (
		select person_id
		from {CHUNK_SCHEMA}.chunk_person
		where chunk_id = {CHUNK_ID}
	),
	t1 as (
		select c.patid, c.consid, c.consdate, c.staffid, c.consmedcodeid
		from cte1
		inner join {SOURCE_SCHEMA}.consultation c on cte1.person_id = c.patid
		where c.consdate is not NULL
	),
	t2 as (
		select t1.*,
		vd.visit_occurrence_id, v.visit_detail_id
		from t1
		left join {SOURCE_SCHEMA}.temp_visit_detail v on t1.consid = v.visit_detail_source_id
		left join {TARGET_SCHEMA}.visit_detail vd on v.visit_detail_id = vd.visit_detail_id
		where v.source_table = 'Consultation'
	)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (domain_id, person_id, visit_occurrence_id, visit_detail_id, provider_id, concept_id, source_value,
										 source_concept_id, type_concept_id, start_date, end_date, start_time, days_supply, dose_unit_concept_id,
										 dose_unit_source_value, effective_drug_dose, lot_number, modifier_source_value, operator_concept_id, qualifier_concept_id,
										 qualifier_source_value, quantity, range_high, range_low, refills, route_concept_id, route_source_value,
										 sig, stop_reason, unique_device_id, unit_concept_id, unit_source_value, value_as_concept_id, value_as_number,
										 value_as_string, value_source_value, anatomic_site_concept_id, disease_status_concept_id, specimen_source_id,
										 anatomic_site_source_value, disease_status_source_value, modifier_concept_id, stem_source_table, stem_source_id)
select NULL,
		t2.patid,
		t2.visit_occurrence_id,
		t2.visit_detail_id,
		t2.staffid,
		NULL::int,
		case when m.cleansedreadcode is null
			then concat(cast(m.snomedctconceptid as varchar) ,'-',m.term)
			else concat(m.cleansedreadcode,'-',m.term)
		end as source_value,
		case when m.cleansedreadcode is null
			then t.SNOMED_source_concept_id
			else t.Read_source_concept_id
		end as source_concept_id,
		32817,
		t2.consdate,
		t2.consdate,
		'00:00:00'::time,
		NULL::int,
		0,
		NULL,
		NULL,
		NULL,
		NULL,
		0,
		0,
		NULL,
		NULL::double precision,
		NULL::double precision,
		NULL::double precision,
		NULL::int,
		0,
		NULL,
		NULL,
		NULL,
		NULL,
		0,
		NULL,
		0,
		NULL::double precision,
		NULL,
		NULL,
		0,
		0,
		NULL,
		NULL,
		NULL,
		0,
		'Consultation',
		t2.consid
from t2
left join {SOURCE_SCHEMA}.medicaldictionary m on t2.consmedcodeid = m.medcodeid
left join {SOURCE_SCHEMA}.temp_concept_map t on t2.consmedcodeid = t.medcodeid;


--insert into stem_source table from drugissue
WITH cte2 as (
		select person_id
		from {CHUNK_SCHEMA}.chunk_person
		where chunk_id = {CHUNK_ID}
	),
	t1 as (
		select d.patid, d.staffid, d.issuedate, d.duration, d.quantity, d.issueid, d.prodcodeid, d.quantunitid, d.probobsid
		from cte2
		inner join {SOURCE_SCHEMA}.drugissue d on cte2.person_id = d.patid 
	),
	t2 as (
		select t1.*, v.visit_detail_id, v.visit_detail_source_id, v.source_table 
		from t1
		left join {SOURCE_SCHEMA}.temp_visit_detail v on t1.probobsid = v.visit_detail_source_id
		and v.source_table = 'Observation'
	)		
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (domain_id, person_id, visit_occurrence_id, visit_detail_id, provider_id, concept_id, source_value,
										 source_concept_id, type_concept_id, start_date, end_date, start_time, days_supply, dose_unit_concept_id,
										 dose_unit_source_value, effective_drug_dose, lot_number, modifier_source_value, operator_concept_id, qualifier_concept_id,
										 qualifier_source_value, quantity, range_high, range_low, refills, route_concept_id, route_source_value,
										 sig, stop_reason, unique_device_id, unit_concept_id, unit_source_value, value_as_concept_id, value_as_number,
										 value_as_string, value_source_value, anatomic_site_concept_id, disease_status_concept_id, specimen_source_id,
										 anatomic_site_source_value, disease_status_source_value, modifier_concept_id, stem_source_table, stem_source_id)
select 	NULL,
		t2.patid,
		vd.visit_occurrence_id, -- not sure why this makes some chunks to hang. Showing the full vd record as below works. ???
		t2.visit_detail_id,
		t2.staffid as provider_id,
		NULL::int,
		dc.dmdid as source_value,
		t.dmd_source_concept_id as source_concept_id,
		32838,
		t2.issuedate,
		case when t2.duration is null then t2.issuedate
			when t2.duration <= 0 then t2.issuedate
			else t2.issuedate + (t2.duration-1) * INTERVAL '1 day'
		end as end_date,
		'00:00:00'::time,
		case when t2.duration < 0 then null else t2.duration end,
		0,
		q.description,
		NULL,
		NULL,
		NULL,
		0,
		0,
		NULL,
		t2.quantity,
		NULL::double precision,
		NULL::double precision,
		NULL::double precision,
		0 as route_concept_id,
		left(routeofadministration,50) as route_source_value,
		NULL,
		NULL,
		NULL,
		0,
		NULL,
		0,
		NULL::double precision,
		NULL,
		NULL,
		0,
		0,
		NULL,
		NULL,
		NULL,
		0,
		'DrugIssue',
		t2.issueid
from t2
left join {SOURCE_SCHEMA}.productdictionary dc on t2.prodcodeid = dc.prodcodeid
left join {SOURCE_SCHEMA}.quantunit q	on t2.quantunitid = q.quantunitid
left join {SOURCE_SCHEMA}.temp_drug_concept_map t on t2.prodcodeid = t.prodcodeid
left join {TARGET_SCHEMA}.visit_detail vd on t2.visit_detail_id = vd.visit_detail_id -- not sure why this makes some chunks to hang. Showing the full vd record as above works. ???
--and d.issuedate is not null -- it is always not null
;

--insert into stem_source table from referral
WITH cte3 as (
		select person_id
		from {CHUNK_SCHEMA}.chunk_person
		where chunk_id = {CHUNK_ID}
	),
	t1 as (
		select r.patid, r.refservicetypeid, r.obsid
		from cte3
		inner join {SOURCE_SCHEMA}.referral r on  cte3.person_id = r.patid
	),
	t2 as (
		select t1.*, v.visit_detail_id, v.visit_detail_source_id, v.source_table, vd.visit_occurrence_id, vd.visit_detail_start_date, vd.visit_detail_end_date
		from t1
		left join {SOURCE_SCHEMA}.temp_visit_detail v on t1.obsid = v.visit_detail_source_id
		inner join {TARGET_SCHEMA}.visit_detail vd on v.visit_detail_id = vd.visit_detail_id
		where v.source_table = 'Observation'
	)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (domain_id, person_id, visit_occurrence_id, visit_detail_id, provider_id, concept_id, source_value,
										 source_concept_id, type_concept_id, start_date, end_date, start_time, days_supply, dose_unit_concept_id,
										 dose_unit_source_value, effective_drug_dose, lot_number, modifier_source_value, operator_concept_id, qualifier_concept_id,
										 qualifier_source_value, quantity, range_high, range_low, refills, route_concept_id, route_source_value,
										 sig, stop_reason, unique_device_id, unit_concept_id, unit_source_value, value_as_concept_id, value_as_number,
										 value_as_string, value_source_value, anatomic_site_concept_id, disease_status_concept_id, specimen_source_id,
										 anatomic_site_source_value, disease_status_source_value, modifier_concept_id, stem_source_table, stem_source_id)
select NULL,
			t2.patid,
			t2.visit_occurrence_id,
			t2.visit_detail_id,
			NULL::bigint,
			0,
			'Referral record',
			0,
			32842,
			t2.visit_detail_start_date,
			t2.visit_detail_end_date,
			'00:00:00'::time,
			NULL::int,
			0,
			NULL,
			NULL,
			NULL,
			NULL,
			0,
			0,
			NULL,
			NULL::double precision,
			NULL::double precision,
			NULL::double precision,
			NULL::double precision,
			0,
			NULL,
			NULL,
			NULL,
			NULL,
			0,
			NULL,
			case when t2.refservicetypeid = 1 then 0
				when t2.refservicetypeid = 2 then 45884011
				when t2.refservicetypeid = 3 then 36308045
				when t2.refservicetypeid = 4 then 45876918
				when t2.refservicetypeid = 5 then 45882580
				when t2.refservicetypeid = 6 then 0
				when t2.refservicetypeid = 7 then 36308045
				when t2.refservicetypeid = 8 then 45885153
				when t2.refservicetypeid = 9 then 706505
				when t2.refservicetypeid = 10 then 45880650
				when t2.refservicetypeid = 11 then 45884467
				when t2.refservicetypeid = 12 then 45876494
				when t2.refservicetypeid = 13 then 706352
			else 0 end,
			NULL::double precision,
			rs.description,
			t2.refservicetypeid,
			0,
			0,
			NULL,
			NULL,
			NULL,
			0,
			'Referral',
			t2.obsid
from t2 
left join {SOURCE_SCHEMA}.refservicetype rs on t2.refservicetypeid = rs.refservicetypeid;
--	where v.visit_detail_start_date is not null  -- visit_detail_start_date was made NULL in map_in_chunks_initial

create index idx_stem_source_{CHUNK_ID} on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (source_concept_id);

-----------------------------------------
-- UPDATE CHUNK
-----------------------------------------
update {CHUNK_SCHEMA}.chunk 
set stem_source_tbl = concat('stem_source_',{CHUNK_ID}::varchar)
where chunk_id = {CHUNK_ID};