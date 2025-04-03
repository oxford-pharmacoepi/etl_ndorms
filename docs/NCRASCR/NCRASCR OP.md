---
layout: default
title: Observation Period
nav_order: 2
parent: NCRASCR 
has_children: true
description: "NCRASCR Observation Period"
---

# CDM Table name: observation_period

## Reading from tumour, treatment, linkage_coverage

![](images/ncrascr_op.png)

| Destination Field | Source field | Logic | Comment field | 
| --- | --- | --- | --- |
| observation_period_id | | | Autogenerate| 
| person_id | e_patid |  |  | 
| observation_period_start_date | diagnosisdatebest<br>eventdate<br>start | GREATEST(LEAST(MIN(diagnosisdatebest), MIN(eventdate)), start) | |
| observation_period_end_date | diagnosisdatebest<br>eventdate<br>end | LEAST(GREATEST(MAX(diagnosisdatebest), MAX(eventdate)), end) | |
| period_type_concept_id | | [32880 - Standard algorithm](https://athena.ohdsi.org/search-terms/terms/32880) |
