# Load required libraries
library(tidyverse)
library(rvest)
library(dplyr)


# Define the URL for COVID-19 data
url <- "https://www.worldometers.info/coronavirus/"

# Step 1: Scrape the table
covid_raw <- url %>%
  read_html() %>%
  html_table(fill = TRUE) %>%
  .[[1]]
view(covid_raw)
# Step 2: Clean column names (snake_case) with base R only, and fix any empty/NA names
names(covid_raw) <- names(covid_raw) %>%
  gsub("[^[:alnum:]]+", "_", .) %>%
  tolower() %>%
  gsub("_+", "_", .) %>%
  gsub("^_|_$", "", .)

# Check if any column names are NA or blank and fix them
if(any(is.na(names(covid_raw)) | names(covid_raw) == "")) {
  fix_idx <- which(is.na(names(covid_raw)) | names(covid_raw) == "")
  names(covid_raw)[fix_idx] <- paste0("col", fix_idx)
}

# Step 3: Remove commas and plus signs from all columns (for numeric conversion)
covid_clean <- covid_raw %>%
  mutate(across(everything(), ~gsub(",|\\+", "", .)))

# Step 4: Trim whitespace from all columns
covid_clean <- covid_clean %>%
  mutate(across(everything(), ~trimws(.)))

# Step 5: Convert numeric columns to numeric type (adjust column range as needed)
num_cols <- names(covid_clean)[3:(ncol(covid_clean)-1)]
covid_clean <- covid_clean %>%
  mutate(across(all_of(num_cols), as.numeric))

# Step 6: Replace empty strings with NA
covid_clean[covid_clean == ""] <- NA

covid_clean = covid_clean %>% select(-newrecovered)
view(covid_clean)
covid_clean$active_cases_1m_pop = as.numeric(covid_clean$active_cases_1m_pop)
# Step 7: Remove rows with missing/blank country names or summary ("Total:")
covid_clean <- covid_clean %>%
  filter(!is.na(country_other) & country_other != "" & country_other != "Total:")
covid_clean = covid_clean %>%
  select(-continent,-newcases,-newdeaths,-new_cases_1m_pop,-new_deaths_1m_pop)

# Step 8: Remove continent rows and World total (keep only countries)
covid_countries <- covid_clean %>%
  filter(!is.na(col1)) %>%  # col1 has rank numbers for countries only
  select(-col1)  # Remove the rank column

# Check dimensions
cat("Number of countries:", nrow(covid_countries), "\n")

glimpse(covid_countries)
# Step 9: View the cleaned data structure
view(covid_countries)




# Create new calculated variables
covid_analysis <- covid_countries %>%
  mutate(
    # Case Fatality Rate (CFR)
    cfr = (totaldeaths / totalcases) * 100,
    
    # Recovery Rate
    recovery_rate = (totalrecovered / totalcases) * 100,
    
    # Active Case Rate
    active_case_rate = (activecases / totalcases) * 100,
    
    # Testing Rate per case
    tests_per_case = totaltests / totalcases,
    
    # Population category
    pop_category = case_when(
      population < 1e6 ~ "Small (<1M)",
      population >= 1e6 & population < 10e6 ~ "Medium (1-10M)",
      population >= 10e6 & population < 100e6 ~ "Large (10-100M)",
      population >= 100e6 ~ "Very Large (>100M)",
      TRUE ~ "Unknown"
    ),
    
    # Testing intensity category
    testing_category = case_when(
      tests_1m_pop < 100000 ~ "Low Testing",
      tests_1m_pop >= 100000 & tests_1m_pop < 1000000 ~ "Medium Testing",
      tests_1m_pop >= 1000000 ~ "High Testing",
      TRUE ~ "Unknown"
    )
  )

# View new variables
head(covid_analysis %>% select(country_other, cfr, recovery_rate, active_case_rate, tests_per_case))

# Detailed missing value analysis
missing_summary <- covid_analysis %>%
  summarise(across(everything(), ~sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "missing_count") %>%
  mutate(
    missing_percentage = (missing_count / nrow(covid_analysis)) * 100
  ) %>%
  arrange(desc(missing_percentage))

print(missing_summary)

# Summary statistics for key variables
desc_stats <- covid_analysis %>%
  select(totalcases, totaldeaths, totalrecovered, activecases, 
         tot_cases_1m_pop, deaths_1m_pop, tests_1m_pop,
         cfr, recovery_rate, active_case_rate) %>%
  summary()

print(desc_stats)

# More detailed statistics
detailed_stats <- covid_analysis %>%
  select(totalcases, totaldeaths, totalrecovered, activecases, 
         tot_cases_1m_pop, deaths_1m_pop, tests_1m_pop,
         cfr, recovery_rate, active_case_rate) %>%
  summarise(across(everything(), 
                   list(
                     mean = ~mean(., na.rm = TRUE),
                     median = ~median(., na.rm = TRUE),
                     sd = ~sd(., na.rm = TRUE),
                     min = ~min(., na.rm = TRUE),
                     max = ~max(., na.rm = TRUE),
                     q25 = ~quantile(., 0.25, na.rm = TRUE),
                     q75 = ~quantile(., 0.75, na.rm = TRUE)
                   ),
                   .names = "{.col}_{.fn}"))

# Transpose for better readability
detailed_stats_long <- detailed_stats %>%
  pivot_longer(everything(), names_to = "stat", values_to = "value") %>%
  separate(stat, into = c("variable", "statistic"), sep = "_(?=[^_]+$)")

print(detailed_stats_long)

# Top 10 countries by different metrics
top10_cases <- covid_analysis %>%
  arrange(desc(totalcases)) %>%
  select(country_other, totalcases, tot_cases_1m_pop) %>%
  head(10)

top10_deaths <- covid_analysis %>%
  arrange(desc(totaldeaths)) %>%
  select(country_other, totaldeaths, deaths_1m_pop) %>%
  head(10)

top10_cfr <- covid_analysis %>%
  filter(!is.na(cfr), !is.infinite(cfr)) %>%
  arrange(desc(cfr)) %>%
  select(country_other, totalcases, totaldeaths, cfr) %>%
  head(10)

top10_testing <- covid_analysis %>%
  filter(!is.na(tests_1m_pop)) %>%
  arrange(desc(tests_1m_pop)) %>%
  select(country_other, totaltests, tests_1m_pop, population) %>%
  head(10)

top10_cases_per_capita <- covid_analysis %>%
  filter(!is.na(tot_cases_1m_pop)) %>%
  arrange(desc(tot_cases_1m_pop)) %>%
  select(country_other, totalcases, tot_cases_1m_pop, population) %>%
  head(10)

# Print results
print("=== TOP 10 COUNTRIES BY TOTAL CASES ===")
print(top10_cases)

print("\n=== TOP 10 COUNTRIES BY TOTAL DEATHS ===")
print(top10_deaths)

print("\n=== TOP 10 COUNTRIES BY CASE FATALITY RATE ===")
print(top10_cfr)

print("\n=== TOP 10 COUNTRIES BY TESTING (per million) ===")
print(top10_testing)

print("\n=== TOP 10 COUNTRIES BY CASES PER CAPITA ===")
print(top10_cases_per_capita)

# Calculate correlation matrix
cor_data <- covid_analysis %>%
  select(totalcases, totaldeaths, totalrecovered, activecases,
         tot_cases_1m_pop, deaths_1m_pop, tests_1m_pop,
         population, cfr, recovery_rate, tests_per_case) %>%
  na.omit()

cor_matrix <- cor(cor_data)
print(cor_matrix)

# Create correlation heatmap with ggplot2
cor_long <- cor_matrix %>%
  as.data.frame() %>%
  rownames_to_column("var1") %>%
  pivot_longer(-var1, names_to = "var2", values_to = "correlation")

# Display and save
p_cor <- ggplot(cor_long, aes(x = var1, y = var2, fill = correlation)) +
  geom_tile(color = "white") +
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", 
                       midpoint = 0, limit = c(-1, 1),
                       name = "Correlation") +
  geom_text(aes(label = round(correlation, 2)), size = 2.5) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 9),
        axis.text.y = element_text(size = 9),
        axis.title = element_blank(),
        plot.title = element_text(hjust = 0.5, face = "bold")) +
  labs(title = "COVID-19 Variables Correlation Matrix") +
  coord_fixed()

# Save to file
ggsave("correlation_plot.png", p_cor, width = 12, height = 10, dpi = 120)

print("Correlation plot saved as correlation_plot.png!")

# Find strongest correlations
cor_pairs <- cor_matrix %>%
  as.data.frame() %>%
  rownames_to_column("var1") %>%
  pivot_longer(-var1, names_to = "var2", values_to = "correlation") %>%
  filter(var1 != var2) %>%
  filter(abs(correlation) > 0.7) %>%
  arrange(desc(abs(correlation)))

print("=== STRONG CORRELATIONS (|r| > 0.7) ===")
print(cor_pairs)

# Check distributions and identify skewness
distribution_stats <- covid_analysis %>%
  select(totalcases, totaldeaths, tot_cases_1m_pop, deaths_1m_pop, 
         tests_1m_pop, cfr, recovery_rate) %>%
  summarise(across(everything(), 
                   list(
                     skewness = ~(mean(., na.rm = TRUE) - median(., na.rm = TRUE)) / sd(., na.rm = TRUE)
                   ),
                   .names = "{.col}_skew"))

print("=== DISTRIBUTION SKEWNESS ===")
print(distribution_stats)

# Analysis by population category
pop_analysis <- covid_analysis %>%
  filter(pop_category != "Unknown") %>%
  group_by(pop_category) %>%
  summarise(
    n_countries = n(),
    avg_cases = mean(totalcases, na.rm = TRUE),
    avg_deaths = mean(totaldeaths, na.rm = TRUE),
    avg_cfr = mean(cfr, na.rm = TRUE),
    avg_tests_per_million = mean(tests_1m_pop, na.rm = TRUE)
  )

print("=== ANALYSIS BY POPULATION CATEGORY ===")
print(pop_analysis)
write.csv(pop_analysis, "population_category_analysis.csv", row.names = FALSE)

# Analysis by testing intensity
testing_analysis <- covid_analysis %>%
  filter(testing_category != "Unknown") %>%
  group_by(testing_category) %>%
  summarise(
    n_countries = n(),
    avg_cfr = mean(cfr, na.rm = TRUE),
    avg_deaths_per_million = mean(deaths_1m_pop, na.rm = TRUE),
    avg_cases_per_million = mean(tot_cases_1m_pop, na.rm = TRUE)
  )

print("=== ANALYSIS BY TESTING INTENSITY ===")
print(testing_analysis)

# Detect outliers using IQR method
detect_outliers <- function(x) {
  q1 <- quantile(x, 0.25, na.rm = TRUE)
  q3 <- quantile(x, 0.75, na.rm = TRUE)
  iqr <- q3 - q1
  lower <- q1 - 1.5 * iqr
  upper <- q3 + 1.5 * iqr
  return(x < lower | x > upper)
}

outlier_countries <- covid_analysis %>%
  mutate(
    cases_outlier = detect_outliers(totalcases),
    deaths_outlier = detect_outliers(totaldeaths),
    cfr_outlier = detect_outliers(cfr),
    testing_outlier = detect_outliers(tests_1m_pop)
  ) %>%
  filter(cases_outlier | deaths_outlier | cfr_outlier | testing_outlier) %>%
  select(country_other, totalcases, totaldeaths, cfr, tests_1m_pop,
         cases_outlier, deaths_outlier, cfr_outlier, testing_outlier)

print("=== OUTLIER COUNTRIES ===")
print(outlier_countries)




