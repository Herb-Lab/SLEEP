# SLeep and Environmental Exposure evaluation framework for urban Populations (SLEEP)

**This repository contains all the essential code for the SLEEP framework.**

It includes:

- 📊 **[R 4.3.2](https://cran.r-project.org/bin/windows/base/old/4.3.2/)** code for regression modeling of sleep health risks, including:
  - Obstructive sleep apnea model
  - Sleep efficiency model
- 📊 ****[R 4.3.2](https://cran.r-project.org/bin/windows/base/old/4.3.2/)** code for quantifying sleep health disparities**
- 🏠 **EnergyPlus `.idf` file** for integrating sleep health models into building energy simulations

These resources support simulation-based assessments of sleep-related health risks in urban residential environments.

## Project Index

### 1. Sleep Health Model Development

#### Obstructive Sleep Apnea Model

| File | Description |
|------|-------------|
| [01_Load_library_and_function.R](./1_Sleep_health_model_development/Obstructive_sleep_apnea_model/01_Load_library_and_function.R) | Loads the required R packages and functions. |
| [02_Regression.R](./1_Sleep_health_model_development/Obstructive_sleep_apnea_model/02_Regression.R) | Performs regression modeling for the Obstructive Sleep Apnea model. |

#### Sleep Efficiency Model

| File | Description |
|------|-------------|
| [01_Load_library_and_function.R](./1_Sleep_health_model_development/Sleep_efficiency_model/01_Load_library_and_function.R) | Loads the required R packages and functions. |
| [02_Regression.R](./1_Sleep_health_model_development/Sleep_efficiency_model/02_Regression.R) | Performs regression modeling for the Sleep Efficiency model. |

---

### 2. SLeep and Environmental Exposure Evaluation Framework for Urban Populations (SLEEP)

| File | Description |
|------|-------------|
| [in.idf](./2_SLeep_and_Environmental_Exposure_evaluation_framework_for_urban_Populations_(SLEEP)/in.idf) | Example EnergyPlus `.idf` file from [ResStock v3.2.0](https://resstock.readthedocs.io/en/v3.2.0/), integrated with automated sleep health risk estimation. |
| [Integrating_sleep_model_into_idf_files.py](./2_SLeep_and_Environmental_Exposure_evaluation_framework_for_urban_Populations_(SLEEP)/Integrating_sleep_model_into_idf_files.py) | Python script for embedding sleep health models into EnergyPlus `.idf` files. |

