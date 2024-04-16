DROP TABLE IF EXISTS {SOURCE_SCHEMA}.daysupply_modes;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.daysupply_modes
(
    id SERIAL NOT NULL,
    prodcode integer NOT NULL,
    numdays smallint NOT NULL
)TABLESPACE pg_default;

ALTER TABLE {SOURCE_SCHEMA}.daysupply_modes ADD CONSTRAINT xpk_daysupply_modes PRIMARY KEY (id) USING INDEX TABLESPACE pg_default;

DROP INDEX IF EXISTS {SOURCE_SCHEMA}.daysupply_modes_prodcode_idx;

insert into {SOURCE_SCHEMA}.daysupply_modes (prodcode,numdays)
select b.prodcode, b.numdays as dayssupply 
from 
    (select a.prodcode, a.numdays, a.daycount, ROW_NUMBER() over (partition by a.prodcode order by a.prodcode, a.daycount desc) AS RowNumber
    from 
        (select prodcode, numdays, count(patid) as daycount from {SOURCE_SCHEMA}.therapy where (numdays > 0 and numdays <=365) and prodcode>1 group by prodcode, numdays) a ) b 
where RowNumber=1;

CREATE INDEX daysupply_modes_prodcode_idx ON {SOURCE_SCHEMA}.daysupply_modes USING btree (prodcode) TABLESPACE pg_default;

DROP TABLE IF EXISTS {SOURCE_SCHEMA}.daysupply_decodes;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.daysupply_decodes
(
    id SERIAL NOT NULL,
    prodcode integer NOT NULL,
    daily_dose numeric(15,3) NOT NULL,
    qty numeric(9,2) NOT NULL,
    numpacks integer NOT NULL,
    numdays smallint NOT NULL
)TABLESPACE pg_default;

ALTER TABLE {SOURCE_SCHEMA}.daysupply_decodes ADD CONSTRAINT xpk_daysupply_decodes PRIMARY KEY (id) USING INDEX TABLESPACE pg_default;

DROP INDEX IF EXISTS {SOURCE_SCHEMA}.daysupply_decodes_prodcode_idx;

insert into {SOURCE_SCHEMA}.daysupply_decodes (prodcode,daily_dose, qty,numpacks, numdays)
select b.prodcode, b.daily_dose, b.qty, b.numpacks, b.numdays 
from 
(select *, ROW_NUMBER() over (partition by prodcode, daily_dose, qty, numpacks order by daycount desc) AS RowNumber 
    from 
        (select prodcode, case when c.daily_dose is null then 0 else c.daily_dose end as daily_dose, 
		case when qty is null then 0 else qty end as qty, 
		case when numpacks is null then 0 else numpacks end as numpacks, 
        numdays, COUNT(prodcode) as daycount 
		from {SOURCE_SCHEMA}.therapy t 
		left join {SOURCE_SCHEMA}.common_dosages c on t.dosageid = c.dosageid 
		where (numdays > 0 and numdays <=365) and prodcode>1 
        group by prodcode, case when c.daily_dose is null then 0 else c.daily_dose end, case when qty is null then 0 else qty end, case when numpacks is null then 0 else numpacks end, numdays) a 
) b 
where RowNumber = 1;

CREATE INDEX daysupply_decodes_prodcode_idx ON {SOURCE_SCHEMA}.daysupply_decodes USING btree (prodcode) TABLESPACE pg_default;