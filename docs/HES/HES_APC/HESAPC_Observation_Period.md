---
layout: default
title: Observation Period
nav_order: 3
parent: HES APC
description: "OBSERVATION_PERIOD mapping from hes_hospital table"

---


# CDM Table name: OBSERVATION_PERIOD (CDM v5.3 / v5.4)

## Reading from hes_hospital,hes_episodes.
Use the hes_hospital & hes_episodes tables to populate the observation_period table.

![](../images/image13.png)

**Figure.1**

| Destination Field | Source field | Logic | Comment field |
| --- | --- | :---: | --- |
| observation_period_id |  |  |  Autogenerate|
| person_id | patid| | |
| observation_period_start_date | hes_hospital.admidate,<br>hes_episodes.epistart | use the earliest of (hes_hospital.admidate, hes_episodes.epistart) that is not null.| |
| observation_period_end_date | hes_hospital.discharged,<br>hes_episodes.epiend | use the latest of (hes_hospital.discharged, hes_episodes.epiend) that is not null | |
| period_type_concept_id | | [32880 - Standard algorithm](https://athena.ohdsi.org/search-terms/terms/32880)| | 