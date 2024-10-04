---
layout: default
title: Observation_Period
nav_order: 3
parent: HES A&E
description: "OBSERVATION_PERIOD mapping from hes_hospital table"

---


# CDM Table name: OBSERVATION_PERIOD (CDM v5.3 / v5.4)

## Reading from hesae_attendance.
Use the hesae_attendance table to populate the observation_period table.

![](images/image15.png)

**Figure.1**

| Destination Field | Source field | Logic | Comment field |
| --- | --- | :---: | --- |
| observation_period_id |  | nextval('public.observation_period_seq') AS observation_period_id |  Autogenerate|
| person_id | patid| | |
| observation_period_start_date | arrivaldate | Retrieve the earliest date among those dates like this: LEAST(MIN(arrivaldate),linkage_coverag.end) AS min_date| |
| observation_period_end_date | arrivaldate | Retrieve the latest date among the date fields like this: GREATEST(MIN(arrivaldate), linkage_coverag.start) AS max_date | |
| period_type_concept_id | | 32880 | |