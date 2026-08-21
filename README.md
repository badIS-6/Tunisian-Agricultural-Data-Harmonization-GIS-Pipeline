# Tunisian Agricultural Data Harmonization & GIS Pipeline

This is a data processing and geospatial pipeline for transforming raw Tunisian agricultural datasets into standardized, GIS-ready spatial layers.

The project focuses on **data harmonization, metadata, administrative-region matching, and spatial transformation** of agricultural datasets related to Tunisia. It was developed as part of the **Smart SDG Tunisia – Manouba School of Engineering 2026 internship**.

## Overview
Tunisian agricultural datasets can be valuable for statistical analysis while still being difficult to use directly in GIS applications. Common issues include:
* Inconsistent administrative region names
* Arabic/French naming differences
* Missing or inconsistent geographic identifiers
* Different field structures and units
* Non-spatial datasets without coordinates
* Lack of standardized links between statistical data and geographic boundaries

We will provides a workflow to clean and harmonize these datasets and transform them into spatial layers suitable for visualization and analysis in **QGIS, ArcGIS, or other GIS software**.

## Objectives
The project aims to:
* Normalize inconsistent regional naming across agricultural datasets.
* Resolve Arabic and French administrative naming conflicts.
* Create a unified `region_id` for geographic matching.
* Link statistical agricultural datasets with Tunisian administrative boundaries.
* Convert non-spatial agricultural data into GIS-compatible formats.
* Generate reproducible spatial layers for GIS visualization and analysis.
* Provide metadata describing datasets, variables, geographic references, transformations, and output quality.

## Data Sources
The workflow is designed around agricultural datasets obtained from the **ONAGRI-related data catalog**.

The datasets cover 6 categories:
* Forests
* Animal production
* Land development
* Dams & irrigated areas
* Rainfall
* Agricultural products

The raw datasets are organized by category before processing.

A reference `Tunisia.csv` dataset is used to normalize administrative names and establish a unified regional identifier. The reference data was extracted from GIS data provided by **GADM**.

## Example Output
<img width="901" height="684" alt="image" src="https://github.com/user-attachments/assets/4e4e5607-124a-4ea8-af03-547b812b6129" />


## Project Workflow

The complete workflow consists of two main R scripts.

```text
Raw Agricultural Data
        │
        ▼
Data Processing & Normalization
        │
        ├── Arabic/French name harmonization
        ├── Administrative name normalization
        └── region_id creation
        │
        ▼
Clean Data
        │
        ▼
Conversion into GIS Data
        │
        ├── Spatial join
        └── Geometry attachment
        │
        ▼
GIS Layers
        │
        ▼
QGIS / ArcGIS Visualization
```

## 1. Data Processing & Normalization

For each category, run:

```text
1- Data processing & normalization.R
```

This stage:

1. Reads the raw agricultural datasets.
2. Resolves inconsistencies between Arabic and French regional names.
3. Normalizes administrative names using the Tunisia reference dataset.
4. Creates a unified `region_id`.
5. Saves the cleaned datasets in the `Clean data/` directory.

The `region_id` provides the common key required to connect tabular agricultural information with spatial geometries.

After execution, check:

```text
Clean data/
```

## 2. Conversion into GIS Data

After the normalization step, run:

```text
2- Conversion into GIS data.R
```

This stage:
1. Loads the cleaned datasets.
2. Uses `region_id` to join the agricultural data with the Tunisian administrative boundary shapefile.
3. Attaches geographic geometry to the non-spatial datasets.
4. Exports each enriched dataset as an individual shapefile.
5. Stores the resulting GIS layers in the `GIS Layers/` directory.

After execution, check:

```text
GIS Layers/
```

## Visualization
Open a GIS application (QGIS, ArcGIS Pro...).

First, load the reference map:

```text
Tunisia_map/Tunisia_map.shp
```

Then add any generated shapefile from:

```text
GIS Layers/
```
The generated layers can then be visualized, analyzed, and labeled.

## Metadata Framework
Metadata is treated as a **core project deliverable**.

The framework is intended to describe:
* Dataset information
* Variables
* Geographic references
* Temporal information
* Processing and transformation rules
* Data quality
* Final GIS outputs

This makes the resulting spatial datasets easier to **audit, reproduce, update, and compare**.

## Main Challenges

### Geographic Identifiers
Many datasets do not contain a stable regional identifier or coordinates. A synthetic `region_id` is therefore created using the reference dataset.

### Multilingual Naming
Regional names may appear differently in Arabic and French, requiring normalization before datasets can be reliably matched.

### Lack of Spatial Information
Some agricultural datasets are purely tabular and contain no geographic coordinates. The workflow solves this by linking the data to administrative boundary geometries through `region_id`.

## Output
The main output of the pipeline is a collection of **GIS-ready shapefiles** representing agricultural datasets enriched with Tunisian administrative geometries.


The workflow demonstrates how a non-spatial agricultural table can be transformed into a spatial layer through metadata, regional matching, and geometry attachment.

## Reproducibility
The project is designed around a repeatable processing workflow:

```text
Raw Data
   ↓
Normalization
   ↓
Clean Data
   ↓
Spatial Matching
   ↓
GIS Layers
   ↓
Visualization / Analysis
```

To reproduce the workflow:
1. Place the raw agricultural datasets in their appropriate folders on your device.
2. Make sure the reference files and shapefiles are available.
3. Install the required R packages.
4. Update the file paths in the R scripts if necessary.
5. Run `1- Data processing & normalization.R`.
6. Verify the contents of `Clean data/`.
7. Run `2- Conversion into GIS data.R`.
8. Verify the generated layers in `GIS Layers/`.
9. Open the resulting shapefiles in QGIS, ArcGIS, or another GIS application.

## Requirements

* **R**
* Required R packages used by the scripts
* **QGIS**, **ArcGIS**, or another compatible GIS application for visualization
* Raw agricultural datasets
* Reference dataset
* Administrative boundary shapefile

Make sure all file paths are correctly configured before running the scripts.


## Developed under:
**Smart SDG Tunisia – Manouba School of Engineering 2026 Internship**

### Authors

* **Badis Zammouri**
* **Mohamed Chandoul**

### Supervisor

* **Mr. Ali Ben Abbes**

### Data Source
**ONAGRI** (https://www.onagri.nat.tn/)


The project provides a reproducible methodology for harmonizing heterogeneous Tunisian agricultural datasets and transforming them into standardized geospatial outputs suitable for GIS visualization and analysis.
