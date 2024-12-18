---
layout: default
title: Location
nav_order: 3
parent: UKB BASELINE
has_children: true
description: "Location mapping from UK Biobank data"
---

# CDM Table name: LOCATION

In UK biobank, patient and GP location information is absent. The only available information is the [UK Biobank Assessment Centre (Data-Coding 54)](https://biobank.ndph.ox.ac.uk/ukb/field.cgi?id=54), which indicates where participants were recruited.

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| location_id | | | Autogenerate |
| address_1| | | NULL |
| address_2| | | NULL |
| city| | | NULL |
| state| | | NULL |
| zip| | | NULL |
| county| target_concept_name | | |
| location_source_value| | | NULL |
| country_concept_id | | [Data-Coding 54](https://biobank.ndph.ox.ac.uk/ukb/field.cgi?id=54) will be mapped to Geography Concept_id by using UKB_GP_COUNTRY_STCM |
| country_source_value | target_concept_name | using the mapped Geography concept name |
| latitude| | | NULL |
| longitude| | | NULL |



