---
layout: default
title: Observation Period
nav_order: 2
parent: UKB HESIN
description: "Person mapping from source_ukb_hesin.hesin & public_ukb.death tables"

---

# CDM Table name: observation_period (CDM v5.4)

## Reading from source_ukb_hesin.hesin, public_ukb.death

![](../images/image3.png)

| Destination Field | Source field | Logic | Comment field |
| --- | --- | :---: | --- |
| observation_period_id |  | nextval('public.observation_period_seq') AS observation_period_id |  Autogenerate|
| person_id | eid | | |
| observation_period_start_date | admidate,<br>epistart,<br>disdate,<br>epiend | LEAST(MIN(admidate), MIN(epistart),MIN(disdate), MIN(epiend))| |
| observation_period_end_date |death.date_of_death,<br>disdate,<br>epiend,<br>admidate,<br>epistart | LEAST(death.death_date, GREATEST(MAX(disdate), MAX(epiend), MAX(admidate), MAX(epistart)))| |
| period_type_concept_id | | [32880 - Standard algorithm](https://athena.ohdsi.org/search-terms/terms/32880)| |
