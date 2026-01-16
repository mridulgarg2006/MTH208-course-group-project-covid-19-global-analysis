# COVID-19 Global Impact Dashboard

An interactive R Shiny web application analyzing pandemic outcomes across 200+ countries, examining relationships between population size, testing intensity, and mortality metrics.

**Course**: MTH208 - Data Science Lab 1 | **Institution**: IIT Kanpur | **Duration**: July - November 2025

## 🎯 Project Overview

This Shiny dashboard explores critical questions about the COVID-19 pandemic:
- How does testing intensity affect case detection rates?
- Does population size correlate with per-capita mortality?
- What patterns emerge when comparing countries regionally?
- Which countries are statistical outliers in their pandemic response?

The application combines real-time data exploration with statistical rigor, demonstrating advanced data science techniques in a production-ready interactive format.

## 🛠️ Technologies & Tools

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Language** | R 4.x | Primary analysis language |
| **Web Framework** | Shiny (>=1.8.0) | Interactive dashboard |
| **Data Wrangling** | tidyverse (dplyr, tidyr) | Cleaning & transformation |
| **Visualization** | ggplot2, plotly | Static & interactive plots |
| **Statistical Analysis** | corrplot, base R | Correlation matrices, outlier detection |

## 📁 Repository Structure
MTH208-course-group-project-covid-19-global-analysis
/
│
├── app.R # Main Shiny application (run this!)
├── README.md # This file
├── REPORT-1-2.pdf # Detailed statistical report
│
├── Code/ # R scripts for data processing
│ └── cleaning_eda.R # Data cleaning & exploratory analysis
│
├── Data/ # Processed datasets
 ├── covid_analysis.csv # Main analysis dataset (200+ countries)
 ├── covid_countries.csv # Country-level summary statistics
 └── population_category_analysis.csv # Analysis stratified by population size

 
## 🚀 Quick Start Guide

### Prerequisites
- **R** (version 4.0 or higher) - [Download here](https://cran.r-project.org/)
- **RStudio** (recommended) - [Download here](https://www.rstudio.com/products/rstudio/download/)

### Installation & Running

**1. Clone the repository**
```bash
git clone https://github.com/mridulgarg2006/covid-19-shiny-dashboard.git
cd MTH208-course-group-project-covid-19-global-analysis

2. Install required R packages
# Copy and paste into R console:
packages <- c("shiny", "tidyverse", "dplyr", "tidyr", "ggplot2", 
              "plotly", "DT", "corrplot", "readr")
install.packages(packages)

3. Run the application
library(shiny)
runApp("app.R")


## 🔍 Key Insights Discovered

### Statistical Findings

| Metric | Correlation | Interpretation |
|--------|-------------|-----------------|
| Test Positivity ↔ Confirmed Cases | **0.83** | Higher testing intensity = more cases detected (capture bias) |
| Population Size ↔ Per-Capita Mortality | **0.12** | Weak relationship; suggests policy & healthcare matter more |
| Deaths ↔ Total Cases | **0.89** | Strong expected relationship; validates data quality |
| Testing Intensity ↔ CFR | **-0.45** | More testing → lower CFR (mild cases detected) |

### Regional Analysis

**Sub-Saharan Africa**: Avg CFR 2.1%, Recovery Rate 89%, Tests/100K: 1,800
- Lower reported CFR likely due to reduced testing (detection bias)
- High recovery rate suggests younger population demographics

**Europe**: Avg CFR 3.4%, Recovery Rate 92%, Tests/100K: 14,200
- Higher CFR correlates with older population and comprehensive testing
- Robust testing infrastructure catches more severe cases

**South Asia**: Avg CFR 2.8%, Recovery Rate 91%, Tests/100K: 3,500
- Moderate outcomes despite high population density
- Variable testing infrastructure across countries

### Notable Outliers

- **Singapore**: Advanced healthcare system, high testing capacity → CFR 0.08%, exemplary response
- **Yemen**: Healthcare collapse, minimal testing → Estimated CFR 18%+ (likely undercount)
- **Peru**: High per-capita mortality (600/100K) despite moderate CFR → Healthcare system overwhelmed
- **USA**: Large variance across states; national aggregation masks regional disparities
