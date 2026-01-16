COVID-19 Global Impact Dashboard
A Shiny web application that analyzes pandemic outcomes (cases, deaths, recovery rates) across 200+ countries, examining the relationship between population size, testing intensity, and mortality.

Course: MTH208 - Data Science Lab 1, IIT Kanpur | Timeline: July - November 2025

What I Built
An interactive dashboard that lets you:

Filter data by region and time period

Compare countries using scatter plots and time series

Analyze correlations between testing intensity and confirmed cases

Identify statistical outliers and anomalies

The Data
Used real COVID-19 data from Johns Hopkins CSSE, WHO, and Our World in Data covering 200+ countries with metrics like confirmed cases, deaths, recovered cases, and testing numbers.

Key Findings
Strong correlation (0.83) between test positivity rate and confirmed case counts

Weak correlation (0.12) between population size and per-capita mortality (meaning large countries don't necessarily have worse outcomes)

Testing bias detected: Higher testing intensity countries report lower case fatality rates because they catch more mild cases

Identified outliers like Singapore (excellent testing infrastructure, very low CFR) vs Yemen (limited testing, higher reported CFR)

Technologies Used
R (data wrangling with tidyverse, dplyr, tidyr)

Shiny (interactive web interface)

ggplot2 + plotly (data visualization)

Statistical analysis (correlation, outlier detection)

How to Run It
Download R and RStudio

Clone this repo

Install packages: install.packages(c("shiny", "tidyverse", "plotly", "DT"))

Open app.R and click "Run App"

Dashboard opens in your browser

Files Explained
app.R: The Shiny app itself (UI + server logic)

R/cleaning_analysis.R: Data cleaning, transformation, metric computation

data/covid_analysis.csv: Processed dataset with derived metrics

visuals/correlation_plot.png: Heatmap showing relationships between variables

What I Learned
Advanced data wrangling and exploratory data analysis (EDA)

Building interactive web applications with Shiny

Statistical analysis: correlation matrices, outlier detection, trend analysis

Git/GitHub version control for projects

How to communicate findings visually
