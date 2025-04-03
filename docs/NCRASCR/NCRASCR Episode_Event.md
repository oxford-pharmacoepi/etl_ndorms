---
layout: default
title: STEM to Episode Event
nav_order: 7
parent: NCRASCR
has_children: true
description: "NCRASCR to Episode Event"
---

# CDM Table name: Episode Event

## Reading from STEM

All mapped records, regardless of their target domain, that are associated with the same CDM Episode will be linked in the episode_event table using the same episode_id.

![](images/ncrascr_stem_to_episode_event.png)

| Destination Field | Source field | Logic | Comment field | 
| --- | --- | --- | --- |
| episode_id | STEM.id<br>STEM.stem_source_id<br>STEM.concept_id | Look up STEM based on the unique stem_source_id and and concept_id = 32533. | | 
| event_id | STEM.id | PK of the linked CDM records | |
| event_field_concept_id | STEM.domain_id | [1147127](https://athena.ohdsi.org/search-terms/terms/1147127) if STEM.domain_id = 'Condition'<br>[1147138](https://athena.ohdsi.org/search-terms/terms/1147138) if STEM.domain_id = 'Measurement'<br>[1147082](https://athena.ohdsi.org/search-terms/terms/1147082) if STEM.domain_id = 'Procedure'<br>[1147094](https://athena.ohdsi.org/search-terms/terms/1147094) if STEM.domain_id = 'Drug'<br>[1147049](https://athena.ohdsi.org/search-terms/terms/1147049) if STEM.domain_id = 'Specimen'<br>[1147115](https://athena.ohdsi.org/search-terms/terms/1147115) if STEM.domain_id = 'Device'<br>[1147165](https://athena.ohdsi.org/search-terms/terms/1147165) if STEM.domain_id = 'Observation' OR <> ('Condition', 'Measurement', 'Procedure', 'Drug', 'Specimen', 'Device') |  | 