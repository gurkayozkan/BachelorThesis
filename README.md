# The Impact of Government Spending on GDP Growth: Cross-Country Comparison

**Bachelor's Thesis — B.Sc. Economics, Istanbul Technical University (ITU), 2024**

Empirical panel-data analysis of the relationship between government expenditure and GDP per capita growth across ten developed OECD economies.

[Thesis PDF](thesis/Gurkay_Ozkan_Bachelor_Thesis_2024.pdf) · [R Analysis](code/01_panel_analysis.R) · [Analysis Data](data/analysis/thesis_panel_2002_2021.csv) · [Data Dictionary](docs/DATA_DICTIONARY.md)

---

## Overview

This repository contains the research materials for my bachelor's graduation thesis in Economics at **Istanbul Technical University (ITU)**.

The study examines how government expenditure—particularly **public social spending**—is associated with GDP per capita growth in a panel of ten developed OECD economies over **2002–2021**.

The empirical strategy compares pooled OLS, Random Effects, and Fixed Effects specifications. Model-selection and diagnostic tests are then used to select and assess the final specification. Because the selected Fixed Effects model exhibits heteroskedasticity and serial correlation, the reported inference uses **Arellano heteroskedasticity- and serial-correlation-robust standard errors clustered by country**.

The results show a statistically significant negative association between public social spending and GDP per capita growth in the study sample. The thesis also finds a negative association for government education expenditure and a positive association for gross capital formation in the final specification.

> **Interpretation:** The estimates are conditional associations, not definitive causal effects. Potential endogeneity and reverse causality remain important limitations of the research design.

---

## Research Question

> **How is government spending—particularly public social spending—associated with GDP per capita growth in developed OECD economies?**

The empirical model also controls for initial GDP per capita, gross capital formation, government education expenditure, tertiary education attainment, unemployment, and population.

---

## Data

The final analysis dataset is a **balanced panel of 200 country-year observations**:

- **10 countries:** Australia, Austria, Denmark, Iceland, Ireland, Luxembourg, the Netherlands, Norway, Switzerland, and the United States
- **Period:** 2002–2021
- **Frequency:** Annual
- **Missing values:** None in the final analysis dataset
- **Regression sample:** 190 observations after introducing the one-period lag of GDP per capita

### Variables and Sources

| Variable | Description | Source |
|---|---|---|
| `GDPpc` | GDP per capita, PPP | World Bank — World Development Indicators |
| `PSS` | Public social spending as % of GDP | OECD — Social Expenditure Database |
| `GCF` | Gross capital formation as % of GDP | World Bank national accounts data |
| `GES` | Government expenditure on education as % of total government expenditure | UNESCO Institute for Statistics |
| `Educ` | Tertiary education attainment, ages 25–64 | OECD |
| `U` | Unemployment rate | ILOSTAT |
| `POP` | Population | OECD |

See [`docs/DATA_DICTIONARY.md`](docs/DATA_DICTIONARY.md) for definitions and units.

---

## Econometric Methodology

The dependent variable is annual GDP per capita growth, represented by the log difference:

\[
\Delta \ln(GDPpc_{it})
\]

The final model estimates the relationship between GDP per capita growth and public social spending while controlling for initial income, capital formation, education expenditure, educational attainment, unemployment, and population.

The empirical workflow is:

1. Correlation analysis and **Variance Inflation Factor (VIF)** diagnostics
2. Pooled **Ordinary Least Squares (OLS)**
3. **Random Effects (RE)**
4. **Two-way Fixed Effects (FE)** with country and year effects
5. Breusch–Pagan Lagrange Multiplier test for panel effects
6. Hausman specification test for FE versus RE
7. Panel Breusch–Godfrey test for serial correlation
8. Breusch–Pagan test for heteroskedasticity
9. Final FE inference using **Arellano HC0 covariance estimates clustered by country**

The analysis was conducted in **R**, primarily using the `plm`, `lmtest`, `car`, `sandwich`, and `stargazer` packages.

---

## Main Results

### Final Two-Way Fixed Effects Specification

| Variable | Estimate | Robust Std. Error | p-value |
|---|---:|---:|---:|
| `ln(PSS)` | **-0.263** | 0.0856 | 0.0025 |
| Lagged `ln(GDPpc)` | **-0.361** | 0.0680 | <0.001 |
| `ln(GCF)` | **+0.031** | 0.0145 | 0.0327 |
| `ln(GES)` | **-0.118** | 0.0463 | 0.0117 |
| Tertiary education attainment | +0.001 | 0.0013 | 0.6627 |
| Unemployment rate | +0.003 | 0.0030 | 0.2522 |
| `ln(POP)` | -0.096 | 0.1393 | 0.4915 |

### Key Findings

- A **10% increase in public social spending as a share of GDP** is associated with approximately **2.6% lower GDP per capita growth**, holding the other regressors constant.
- A **10% increase in government education expenditure** is associated with approximately **1.2% lower GDP per capita growth** in the estimated short-run relationship.
- **Gross capital formation** has a positive and statistically significant association with GDP per capita growth after robust standard-error correction.
- The negative coefficient on initial GDP per capita is consistent with the convergence mechanism discussed in growth theory.

These estimates should not be interpreted as causal policy effects.

---

## Reproducing the Analysis

### Requirements

Install R and the packages used by the analysis:

```r
install.packages(c("plm", "lmtest", "sandwich", "car", "stargazer"))
```

### Run

From the repository root:

```bash
Rscript code/01_panel_analysis.R
```

The script:

- imports the final panel dataset;
- checks the panel structure and missingness;
- reproduces the correlation matrix and VIF diagnostics;
- estimates the five principal OLS / RE / FE specifications;
- performs the model-selection and diagnostic tests;
- computes Arellano robust standard errors for the final FE model; and
- writes reproducibility outputs to `results/`.

### Validation

The public analysis dataset reproduces:

- the **200 observations and summary statistics** reported in the thesis;
- the **190-observation regression sample** created by the lagged GDP-per-capita term;
- the reported VIF diagnostics; and
- the final Fixed Effects coefficient estimates and robust standard errors reported in the thesis.

The repository begins from the **final analysis dataset**. It does not attempt to fully reconstruct every raw-source download from the original databases; source definitions are documented in the thesis and data dictionary.

---

## Repository Structure

```text
BachelorThesis/
├── README.md
├── CITATION.cff
├── ThesisStudyR.Rproj
├── .gitignore
│
├── code/
│   └── 01_panel_analysis.R
│
├── data/
│   └── analysis/
│       └── thesis_panel_2002_2021.csv
│
├── docs/
│   └── DATA_DICTIONARY.md
│
├── results/
│   └── reference_final_model.csv
│
└── thesis/
    └── Gurkay_Ozkan_Bachelor_Thesis_2024.pdf
```

---

## Limitations

The most important limitation is **endogeneity**. Government spending may affect economic growth, while economic growth may simultaneously affect government spending. Omitted variables and sample selection may also influence the estimated relationships.

Two-way Fixed Effects control for unobserved time-invariant country characteristics and common year effects, but they do not eliminate reverse causality. An Instrumental Variables strategy was considered during the research, but a sufficiently credible instrument was not identified within the scope of the thesis.

The results should therefore be interpreted as empirical associations within this sample of developed OECD economies, not as definitive causal estimates or direct policy prescriptions.

---

## Academic Information

**Author:** Gürkay Özkan  
**Degree:** B.Sc. in Economics  
**Institution:** Istanbul Technical University (ITU)  
**Faculty:** Faculty of Management  
**Department:** Economics  
**Supervisor:** Asst. Prof. Mete Han Yağmur  
**Submission:** January 2024

The research itself was completed in 2024. The repository was subsequently reorganized for clearer public presentation and reproducibility; the empirical specification and reported thesis results were not changed.

---

## Citation

```bibtex
@thesis{ozkan2024government,
  author = {Gürkay Özkan},
  title = {The Impact of Government Spending on GDP Growth: Cross-Country Comparison},
  school = {Istanbul Technical University},
  year = {2024},
  type = {Bachelor's Thesis}
}
```
