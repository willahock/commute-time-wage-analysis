# Commute Time and Wage Income

## Overview

This project examines the relationship between commute time and annual wage income among employed adults in the United States. Using 2024 IPUMS USA microdata, I apply econometric methods in Stata to analyze whether longer commute times are associated with differences in wage income.

## Data

- **Source:** IPUMS USA
- **Year:** 2024
- **Sample:** Employed adults ages 18–65
- **Observations:** 1,392,789

The primary variables used in the analysis include annual wage income, one-way commute time, age, gender, educational attainment, race, and usual weekly work hours.

## Methodology

I use multivariate OLS regression models to estimate the relationship between commute time and wage income.

Annual wage income is transformed using the natural logarithm, while commute time is measured in 10-minute increments. Additional specifications introduce demographic and employment controls and examine whether the relationship between commute time and wages differs by gender.

## Key Findings

- Longer commute times are associated with higher annual wage income.
- The relationship remains positive and statistically significant after including demographic and employment controls.
- The analysis also examines differences in the commute-wage relationship by gender.

## Tools & Skills

- Stata
- Econometric analysis
- OLS regression
- Interaction terms
- Data cleaning
- Statistical interpretation
- Data visualization
- Large-scale microdata analysis

## Repository Contents

- `commute_wage_analysis.do` — Stata code used for data preparation and econometric analysis
- `commute_wage_research_paper.pdf` — Full research paper with methodology, results, and discussion

## Author

**Willa Hock**  
B.A. Economics, Boston University
