###### This is our contribution to the SmartSDG Tunisia platform (Link: https://mse.rnu.tn/smartsdg_tunisia/dashboard.html)

<img width="300" height="300" alt="image" src="https://github.com/user-attachments/assets/a5d13930-71ae-4785-b71d-e9daec503e67" />

# Harmonization of open agricultural data and agricultural analysis in Tunisia
---
## SmartSDG Tunisia

SmartSDG Tunisia is an initiative designed to support the monitoring and analysis of the Sustainable Development Goals (SDGs) in Tunisia. It brings together data, geographic information, and analytical tools in a shared environment, making indicators easier to explore across themes, administrative areas, and time. By organizing and harmonizing information from different sources, the initiative aims to make data more consistent, accessible, and useful for understanding development challenges and supporting evidence-based decisions.

Although SmartSDG Tunisia addresses the broader SDG framework, the data-harmonization pipeline documented in this chapter focuses exclusively on **SDG 2 - Zero Hunger**. It uses open agricultural datasets to prepare standardized, geographically referenced information for agricultural monitoring and spatial and temporal analysis. The other Sustainable Development Goals are outside the scope of this specific pipeline.

## 1 Agricultural Data Analysis

The agricultural data examined in this work belong to a wider landscape of public and institutional information sources. The Tunisian National Agricultural Observatory (ONAGRI), particularly its Agridata open data catalogue, is a prominent national source and an important input to the present analysis, but it is not the only source relevant to SDG 2 monitoring. Complementary sources include FAO databases such as FAOSTAT and FAO-GIEWS, as well as information published by the Ministry of Agriculture and its technical services, the national statistical system, and other sectoral institutions. These sources differ in thematic scope, reporting periods, administrative detail, and measurement units. They should therefore be treated as complementary records that need to be documented and reconciled:

- Agricultural products
- Animal production
- Irrigated areas
- Forests
- Land development
- Rainfall

Together, these themes provide a starting point for examining agricultural activity alongside some of the natural-resource and environmental conditions that shape it.

The studied collection from the ONAGRI includes 132 datasets across the six themes. The coverage is heterogeneous rather than continuous. The periods below are the earliest and latest years listed in the metadata, not proof of an uninterrupted annual series.

| Category | Datasets | Governorates | Years | Main units |
|---|---:|---:|---|---|
| Agricultural products | 49 | 24 | 1901-2024 | Hectares, kg litres, TND |
| Animal production | 20 | 23 | 1900-2025 | Heads, litres |
| Irrigated areas | 30 | 23 | 1900-2024 | m³, %, hectare |
| Forests | 7 | 24 | 1900-2025 | Hectares, quintals, m³ |
| Land development | 21 | 4 | 1914-2024 | Hectares, m³ |
| Rainfall | 5 | 5 | 2020-2025 | %, mm |
| Total | 132 | 24 | 1900-2025 | |

*Figure 1. Metadata description of the 132 ONAGRI datasets.*

Across the six categories, there is category-specific subcategory labels. These cover cereals, fisheries, milk, irrigation, livestock and herds, water resources, forest fires, and rainfall stations.

The data can be approached through several complementary analytical perspectives. A temporal analysis compares observations across reporting years to identify trends, fluctuations, and periods of change. A geographic analysis compares the distribution of indicators across governorates or other administrative units, once regional references have been made consistent. An integrated analysis can place agricultural production alongside related information such as rainfall or irrigated areas, provided that the variables use compatible units, periods, and geographic scales. Where suitable area and production measures are both available, productivity or yield comparisons may also be explored.

These perspectives support practical questions for SDG 2 monitoring: How does crop production evolve over time? Where are the main production areas? How different are regional patterns? And how can agricultural statistics be interpreted together with information on water, land, and other production conditions? SmartSDG Tunisia (SDG 2) was developed to make these questions easier to explore in one monitoring environment. After the source records are prepared and harmonized, the platform presents them through interactive maps, time-series views, regional rankings, and indicator filters.

Wheat production provides a concrete example of this analytical approach. Mapping durum wheat production across Tunisian administrative areas for selected years makes it possible to compare regional patterns, but it also reveals a limitation in the historical records: geographic coverage was not complete in every year. The coverage map shows data for 20 of 24 governorates in 2000 (83.3%), 22 of 24 in 2006 (91.7%), 23 of 24 in 2012 (95.8%), and all 24 in 2018 (100%). In other words, full governorate coverage is reached only in the latest year presented, which was 8 years ago by the time of writing this document.

<img width="750" height="344" alt="image" src="https://github.com/user-attachments/assets/2c6b8ea0-3a72-4390-92fd-49e5bd7f4120" />


*Figure 2. Geographic coverage of the durum wheat production records in the selected years.*

Looking beyond these spatial limitations, the evolution of average wheat production between 2000 and 2018 reveals considerable year-to-year fluctuations. Production reached its highest level in 2003, followed by other notable peaks in 2009 and 2011, while particularly low values were recorded in 2002 and 2010. In recent years, production appears relatively more stable, fluctuating around 340-400.

<img width="750" height="344" alt="image" src="https://github.com/user-attachments/assets/b6730e86-bbbf-475a-a120-1592af6afbd0" />


*Figure 3. Evolution of recorded durum wheat production by selected year (sum of available governorate records, coverage shown for each year).*

SmartSDG Tunisia combines both perspectives, where production occurs and how it evolves over time, providing a stronger basis for monitoring agricultural trends and supporting the Sustainable Goals.


<img width="687" height="406" alt="image" src="https://github.com/user-attachments/assets/342dd084-bfd9-4ed9-a815-01272fc09e5b" />

*Figure 4. Overview of the SmartSDG Tunisia SDG 2 monitoring platform.*

The platform even provides a further step beyond static maps by presenting processed agricultural information in an interactive environment. Following data treatment and harmonization, the prepared data can be explored through spatial filters, thematic filters, temporal filters, and trend views, and can also serve as input to machine-learning experiments and further analysis. The dashboard is therefore both a way to communicate the results and a practical setting in which to assess whether the underlying observations are sufficiently consistent for comparison and modelling.

Once the underlying data problems are addressed, the same foundation can open the way to additional applications such as regional comparisons, scenario analysis, production forecasting, and earlier identification of emerging risks. Harmonization does not by itself guarantee forecast accuracy: model results still depend on the observations available, modelling choices, evaluation, and uncertainty. It does, however, make the data more suitable for these downstream analyses.

## 2 Fragmented Agricultural Data in Tunisia

SmartSDG Tunisia (SDG 2) is intended to bring agricultural indicators into a shared monitoring space where their spatial and temporal patterns can be explored together. Building that view also exposed a practical limitation: the main obstacle is not simply whether agricultural statistics exist, but whether records produced by different sources can be connected reliably to the same places, periods, and variables. The data-preparation work revealed several recurring forms of fragmentation:

- Inconsistent administrative names: the same governorate or locality may appear with different spellings, transliterations, abbreviations, or official naming conventions.
- Arabic/French differences: records may alternate between Arabic and French nomenclatures, creating mismatches between otherwise equivalent administrative areas.
- Missing geographic identifiers: all tables lack a stable regional code or coordinates that could be used to identify their geographic unit directly.
- Different fields and measurement units: variable names, table structures, and units may differ between datasets, complicating comparison and integration.

When these issues are not addressed, analysts must rely on repeated manual cleaning and case-by-case matching. This process is time-consuming, difficult to reproduce, and vulnerable to error. It can delay monitoring and weaken the reliability of regional comparisons. For SDG 2 applications, harmonization must therefore be treated not merely as a technical preparation step, but as part of a broader approach to metadata governance, standardization, and traceability.

## 3 SmartSDG Tunisia’s Geospatial Metadata Framework

To address these barriers, SmartSDG Tunisia uses a metadata framework that makes each dataset easier to identify, interpret, compare, and update. Metadata provides the context needed to understand what a dataset measures, where and when its observations apply, and how its attributes have been prepared. The framework covers five complementary dimensions:

| Metadata dimension | Purpose |
|---|---|
| A. Identification | Uniquely identifies the dataset, its version, and the authoritative source organization. |
| B. Thematic | Defines the agricultural subcategory or subject being measured. |
| C. Temporal | Establishes the time dimension, reporting period, and observation frequency. |
| D. Geographic | Defines the administrative reference and standardizes spatial references using geographic information. |
| E. Attribute | Normalizes field names, variable definitions, and measurement units. |

A consistent metadata record helps preserve the meaning of the original observations while documenting the transformations applied to them. It also makes the resulting datasets more transparent and easier to audit, reproduce, and update.

In figure 1, the metadata table, these dimensions are represented through category, number of datasets and types, publisher/processing information, subcategories, main units, governorates involved, and years covered. For a complete record, the same structure should be extended to include each dataset's exact source title and link, the original publisher, the processing script/version, the date processed, the original and standardized field names, and a definition for every analytical variable.

### Advanced Processing and Regional Matching:

The central processing challenge is to establish a reliable link between statistical records and geographic areas. When source tables do not contain stable geographic keys, administrative names may be the only available matching attribute. The workflow therefore combines bilingual text normalization with administrative-name standardization and matching against a master administrative reference.

Once a consistent regional reference has been established, the workflow assigns a unified region_id. This identifier becomes the common key used to connect the cleaned agricultural tables to Tunisia's administrative boundary data. The attribute fields and measurement units are then checked against the dataset metadata, after which the cleaned records are converted into GIS-compatible layers. The result is a repeatable path from raw agricultural tables, through normalization and regional matching, to spatial datasets that can be inspected both in standard GIS software and integrated into the SmartSDG Tunisia platform.

<img width="894" height="580" alt="image" src="https://github.com/user-attachments/assets/dc12ca08-2039-405b-9660-65e0a2918d69" />

*Figure 5. Processing workflow: six source categories are normalized, matched to the administrative reference, and converted into GIS layers for the SmartSDG Tunisia platform.*

The table below (figure 6) shows the results of a geographic matching-quality test across the processed agricultural datasets: The original labels are compared with the standardized name and region_id. Then, each identifier’s existence is confirmed in the reference geography. Finaly, duplicate or conflicting joins are counted:

| Matching-quality indicator | Value from the processing run |
|---|---:|
| Total number of datasets | 132 |
| Eligible records (rows) evaluated | 5843 |
| Records assigned a valid region_id | 4664 |
| Automatic match rate | 79.82% |
| Duplicate or conflicting joins | 580 |
| Unmatched records | 1179 |

*Figure 6. Geographic matching-quality test and validation results across harmonized agricultural datasets*

The verification process evaluated 5843 eligible agricultural records across the harmonized datasets. Of these, 4664 records (79.82%) were successfully assigned a region_id corresponding to an identifier in the reference geographic dataset. This represents a satisfactory level of geographic correspondence, particularly considering the inconsistencies and limitations inherited from the original open datasets. The remaining unmatched records primarily reflect pre-existing challenges in the source data, including inconsistent geographic naming conventions, incomplete geographic information and difficulties in establishing reliable correspondences with the reference geography. Additionally, 580 records were flagged for potential duplicate or conflicting geographic assignments, highlighting further inconsistencies in the original geographic information that require verification. Overall, the process achieved substantial geographic standardization, improved the consistency of agricultural data and provided a systematic means of identifying and documenting issues that would otherwise complicate their integration and subsequent spatial analysis. The remaining discrepancies constitute opportunities for further refinement rather than evidence of failure.

The data samples below show the same source dataset, the evolution of the number of oil mills in Nabeul (2022-2024), before and after the harmonization process. The majority of the records have been assigned a region_id. Missing values, however, have been assigned as NA.

- **Before the Advanced Processing and Regional Matching:**

<img width="703" height="428" alt="image" src="https://github.com/user-attachments/assets/0d095ecb-9e5a-4c03-b003-3c99c7388ab5" />

- **After the Advanced Processing and Regional Matching:**

<img width="714" height="268" alt="image" src="https://github.com/user-attachments/assets/204b7548-e4b7-4f36-bf0f-c7e0d737b724" />


## 4 Analytical Value

The immediate outcome of the framework is the more systematic conversion of raw, non-spatial agricultural records into documented and interactive geospatial data. These standardized layers are prepared for spatial analysis and can help decision-makers visualize agricultural trends, compare regional production, and assess geographic differences that may be relevant to vulnerability to climate shocks. Where the necessary denominators and compatible measures are available, the same layers can also support comparisons of productivity.

When integrated into platforms such as the SmartSDG Tunisia dashboard, harmonized data can support dynamic trend analysis, forecasting, and interactive mapping of indicators such as cereal production, irrigated-land distribution, and livestock-related information. The wheat-production map and the machine-learning example described below illustrate how a common data foundation can connect historical monitoring with more advanced analytical applications.

## 5 Contributors, Data Credits and References

The SDG 2 chapter and the harmonization pipeline have been developed and are maintained under the responsibility of Badis Zammouri and Mohamed Chandoul, under the scientific supervision of Dr. Ali Ben Abbes. The open agricultural datasets used as inputs were obtained from the Tunisian National Agricultural Observatory (ONAGRI) through its agricultural data catalogue https://www.agridata.tn/. The results, methods, and outputs presented on the SmartSDG Tunisia platform are attributable to this work, unless otherwise indicated through specific citations or acknowledgements.
