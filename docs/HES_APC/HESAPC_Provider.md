---
layout: default
title: Provider
nav_order: 5
parent: HES APC
description: "Provider mapping from HES APC hes_episodes table"

---

# CDM Table name: PROVIDER (CDM v5.3 / v5.4)

## Reading from hes_episodes

Use the hes_episodes table to populate the provider table. In HES APC, the Pconsult field represents the unique identifier given to the consultant which in this case is representing the provider.  

![](images/image3.png)

| Destination Field | Source field | Logic | Comment field |
| --- | --- | :---: | --- |
| provider_id | pconsult | Autogenerate |  |
| provider_name | NULL |  |  |
| npi | NULL |  |  |
| dea | NULL |  |  |
| specialty_concept_id | tretspef,mainspef | 	If tretspef is not null then tretspef else Mainspef, domain_id='provider' and Vocabulary_id='HES Specialty' and standard_concept='s' |  |
| care_site_id |NULL | | |
| year_of_birth | NULL |  |  |
| gender_concept_id | NULL | |  |
| provider_source_value | pconsult |  |  |
| specialty_source_value | tretspef,mainspef | 	If tretspef is not null then tretspef else Mainspef, domain_id='provider' and Vocabulary_id='HES Specialty' and standard_concept='s' |  |
| specialty_source_concept_id | NULL |  | |
| gender_source_value | NULL| |  |
| gender_source_concept_id | NULL |  | |