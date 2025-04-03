---
title: "README"
author: "Francien Veenman"
date: "2025-04-03"
output: html_document
---
# Lung function, current asthma, and oral microbiota

This study is based on data from **The Generation R Study**.  
A dummy dataset is provided to enable the code to run.  
Please be aware that the results are not accurate, as this is dummy data and not biologically true data. Therefore, warnings may arise because the data does not align with the assumptions of the analyses.

## Input

Two dummy data objects are provided:\
- **Phyloseq object**: `"dummy_phyloseq.Robject"`\
- **Long dataframe with the imputed metadata**: `"dummy_imputed_dataframe_long.Rda"`\

Two R scripts are provided:\
- Main analyses script: `"20250403_script_reproducible_lf_curas_om.R"`\
- script with functions: `"functions.R"`\

## Dependencies

The following R packages and versions are required for running the code:

| Package  |Version|
|----------|-------|
| dplyr    | 1.1.2 |
| mice     | 3.14.0|
| phyloseq | 1.40.0|

To install the **phyloseq** package, you can use **BiocManager**:

```
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("phyloseq") ```
