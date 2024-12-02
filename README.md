Here’s an updated **README** for the repository, including details about the additional `advice_inversion.m` script:

---

# README

## **Note: This repository is currently under development.**  
**Do not use this code in its current state. Features and functionality are incomplete and subject to change.**

---

## Model Fitting for Advice Task with Trust Learning

This repository contains MATLAB and Python scripts for modeling, fitting, and simulating behavior in the **Advice Task**. These models incorporate trust learning, decision-making with social advice, and multi-level parameter estimation.

---

## Repository Files

### MATLAB Scripts

1. **`main_advise.m`**  
   - Primary script for running model fitting and simulations.  
   - Configurable for subject-level or simulated data.  
   - Outputs results in `.mat` and `.csv` formats.

2. **`Advice_fit_prolific.m`**  
   - Fits Advice Task models to behavioral data collected from Prolific.  
   - Processes task-specific trial information and estimates model parameters.  
   - Outputs individual fits and summary statistics.

3. **`Simple_Advice_Model_CMG.m`**  
   - Core script for the Advice Task model.  
   - Simulates belief updates and action probabilities using task-specific parameters (`eta`, `omega`, `p_right`, etc.).  
   - Supports various trust and learning dynamics.

4. **`advice_inversion.m`**  
   - Performs model inversion using Variational Bayes.  
   - Estimates posterior distributions and log evidence (free energy) for the model parameters.  
   - Supports two core models: `Simple_Advice_Model_CMG` and `Simple_Advice_Model_CMG_same_num_choices`.

---

### Python Scripts

1. **`runall_advise_fit.py`**  
   - Automates model fitting across multiple subjects using Slurm.  
   - Organizes results into directories and logs.  
   - Configurable for batch processing and high-performance computing.

---

### Key Features

- **Simulation:** Generate synthetic data for validation and testing.  
- **Model Inversion:** Use Variational Bayes to estimate model parameters.  
- **Multi-Level Analysis:** Handle individual and group-level behavior with hierarchical models.  
- **Dynamic Trust Learning:** Models epistemic and pragmatic value computation with advice.  

---

### Usage

1. **MATLAB Workflow:**
   - Configure paths and settings in `main_advise.m` or `Advice_fit_prolific.m`.  
   - Run the script to fit models or simulate data, saving outputs automatically.

2. **Batch Processing with Python:**
   - Update `runall_advise_fit.py` with subject lists and output directories.  
   - Execute the script to submit jobs for large-scale model fitting.

---

### Dependencies

- **MATLAB:** Required for core modeling and analysis.  
- **Python 3.x:** Used for batch processing and Slurm integration.  
- **Slurm:** Needed for high-performance job scheduling.



