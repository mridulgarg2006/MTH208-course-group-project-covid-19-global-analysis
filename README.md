# COVID-19 Data Visualisation App

## Requirements

-   R version 4.1.0 or higher.
-   R packages:
    -   `shiny`
    -   `shinythemes`
    -   `tidyverse`
    -   `dplyr`
    -   `rvest`
    -   `ggplot2`
-   (Optional) RStudio for easier app usage.

## How to Run the App

1.  Open R or RStudio.
2.  Set the working directory to the folder containing the `app`
    folder.
3.  Run: shiny::runApp(“app”)
4.  The app will open in your browser.


## Project Structure
MTH208 PROJECT
├── app/
│ ├── app.R
│ ├── covid_countries.csv
│ ├── correlation.png
│ ├── covid_analysis.csv
├── code/
│ └── cleaning_eda.R
│ └── population_category_analysis.csv
└── README.md


## Notes

- Data is scraped/loaded automatically when the app runs.
- Data source: [Worldometers](https://www.worldometers.info/coronavirus/)

