# SLeep and Environmental Exposure Evaluation Framework for Urban Populations (SLEEP)

This repository contains the code corresponding to the Methods section of the manuscript **_Housing Conditions as Drivers of Pediatric Sleep Disparities in U.S. Cities_.**

It includes:

- 📊 **[R 4.3.2](https://cran.r-project.org/bin/windows/base/old/4.3.2/)** code for regression modeling of sleep health risks, including:
  - Obstructive sleep apnea model
  - Sleep efficiency model
- 📊 **[R 4.3.2](https://cran.r-project.org/bin/windows/base/old/4.3.2/)** code for quantifying sleep health disparities
- 🏠 **[EnergyPlus 23.2.0](https://github.com/NREL/EnergyPlus/releases/tag/v23.2.0)  `.idf` file** with sleep health models integrated into building energy simulations



### 1. Sleep health model development

#### Obstructive sleep apnea model

| File | Description |
|------|-------------|
| [01_Load_library_and_function.R](./1_Sleep_health_model_development/Obstructive_sleep_apnea_model/01_Load_library_and_function.R) | Loads the required R packages and functions. |
| [02_Regression.R](./1_Sleep_health_model_development/Obstructive_sleep_apnea_model/02_Regression.R) | Performs regression modeling for the obstructive sleep apnea model. |

#### Sleep efficiency model

| File | Description |
|------|-------------|
| [01_Load_library_and_function.R](./1_Sleep_health_model_development/Sleep_efficiency_model/01_Load_library_and_function.R) | Loads the required R packages and functions. |
| [02_Regression.R](./1_Sleep_health_model_development/Sleep_efficiency_model/02_Regression.R) | Performs regression modeling for the sleep efficiency model. |

---

### 2. SLeep and Environmental Exposure evaluation framework for urban Populations (SLEEP)

| File | Description |
|------|-------------|
| [in.idf](./2_SLeep_and_Environmental_Exposure_evaluation_framework_for_urban_Populations_(SLEEP)/in.idf) | Example [EnergyPlus 23.2.0](https://github.com/NREL/EnergyPlus/releases/tag/v23.2.0) `.idf` file from [ResStock v3.2.0](https://resstock.readthedocs.io/en/v3.2.0/), integrated with automated sleep health risk estimation. |
| [Integrating_sleep_model_into_idf_files.py](./2_SLeep_and_Environmental_Exposure_evaluation_framework_for_urban_Populations_(SLEEP)/Integrating_sleep_model_into_idf_files.py) | Python script for embedding sleep health models into [EnergyPlus 23.2.0](https://github.com/NREL/EnergyPlus/releases/tag/v23.2.0) `.idf` files. |

### 3. Quantification statistics for sleep disparity
#### Obstructive Sleep Apnea Model

| File | Description |
|------|-------------|
| [01_Load_library.R](./3_Quantification_statistics_for_sleep_disparity/01_Load_library.R) | Loads the required R packages. |
| [02_KL_divergence.R](./3_Quantification_statistics_for_sleep_disparity/02_KL_divergence.R) | Calculates Kullback-Leibler (KL) divergence to quantify similarities in the distribution of sleep health risks among cities. |
| [03_Gini.R](./3_Quantification_statistics_for_sleep_disparity/03_Gini.R) | Computes the Gini coefficient for each city to assess inequality in sleep health risks. |
| [04_City_level_regression_analysis.R](./3_Quantification_statistics_for_sleep_disparity/04_City_level_regression_analysis.R) | Examines the relationship between housing characteristics and sleep health risks at the city level. |
| [05_PCA.R](./3_Quantification_statistics_for_sleep_disparity/05_PCA.R) | Performs principal component analysis (PCA) to explore relationships between building characteristics and sleep health risks. |
