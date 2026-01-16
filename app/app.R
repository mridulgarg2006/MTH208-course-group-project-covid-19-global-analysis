#SHINY APP
library(dplyr)
library(ggplot2)
library(shiny)
library(shinythemes)

#loading the required datasets 

covid_countries=read.csv("covid_countries.csv")
covid_analysis=read.csv("covid_analysis.csv")

# including only the numeric columns for visualization (i.e, removing countries)
numeric_vars <- names(covid_countries)[-1]

#making another subset for studying relevant correlations
new_xvars <- c("totaltests","population")
new_yvars <- c("totaldeaths","totalrecovered")

ui <- fluidPage(
  theme = shinytheme("flatly"),
  tags$head(
    tags$style(HTML("
      body, .tab-content, .well, .container-fluid {
        background-color: lightblue !important;
      }
      .panel, .well {
        background-color: white !important;
      }
      .nav-tabs > li > a, .nav-tabs > li.active > a {
        background-color: #b3e6ff !important;
        color: black !important;
        font-weight: bold;
      }
      h1, h2, h3, h4, h5 {
        color: navy !important;
      }
    "))
  ),
  titlePanel("COVID-19 DATA VISUALISATION "),
  
  tabsetPanel(
    # TAB 1: Displaying Descriptive Statistics via visualising through Histogram
    tabPanel("Descriptive Statistics",
             sidebarLayout(
               sidebarPanel(
                 selectInput("var", "Choose a variable:",
                             choices = numeric_vars,
                             selected = numeric_vars[1])
               ),
               mainPanel(
                 h4(textOutput("varname1")),
                 plotOutput("plot1"),
                 h4("Summary Statistics"),
                 verbatimTextOutput("stats")
               )
             )
    ),
    
    # TAB 2: Horizontal Bar Plot 
    tabPanel("Horizontal Barplot",
             sidebarLayout(
               sidebarPanel(
                 selectInput("variable", "Choose a variable:",
                             choices = numeric_vars,
                             selected = numeric_vars[1])
               ),
               mainPanel(
                 h4(textOutput("varname2")),
                 plotOutput("plot2"),
                 
                 tableOutput("table2")
               
               )
             )
    ),
    
    # TAB 3: Scatterplot 
    tabPanel("Scatterplots",
             sidebarLayout(
               sidebarPanel(
                 selectInput("yvar", "Select the response variable.", 
                             choices = new_yvars,
                             selected = "totaldeaths"),
                 selectInput("xvar", "Select the explanatory variable.", 
                             choices = new_xvars,
                             selected = "totaltests")),
               mainPanel(
                 h4(textOutput("scatter_title")),
                 plotOutput("scatterplot"),
                 textOutput("corr")
               )
             )
    ),
 #TAB 4 

      tabPanel("Country Explorer",
             sidebarLayout(
               sidebarPanel(
                 selectInput("country", "Choose a Country:",
                             choices = covid_countries$country_other,
                             selected = "India")
               ),
               mainPanel(
               h3(textOutput("countryTitle")),
               tableOutput("countryTable"),
               textOutput("message"),
               h4(textOutput("title")),
               tableOutput("rank")
               
                         )
       )),
                             
  #TAB 5 : About 
  tabPanel("About",
      fluidRow(
        # LEFT COLUMN – Data Description
        column(
          width = 6,
          h3("DATA DESCRIPTION"),
          tableOutput("table4")
        ),

        # RIGHT COLUMN – Methodology
        column(
          width = 6,
          h3("DATA CLEANING"),
          verbatimTextOutput("method"),
          br(), br(),
          h3("EXPLORATORY DATA ANALYSIS"),
          tableOutput("eda"),
          br(),br(),
          # Shiny Procedure Block
          h3("SHINY PROCEDURE"),
          verbatimTextOutput("procedure") ))
        
      
    )
))

server <- function(input, output) {
  # TAB 1: Histogram and descriptive stats
  data1 <- reactive({
    covid_countries[[input$var]]
  })
  
  output$varname1 <- renderText({
    paste("Distribution and summary stats for:", input$var)
  })
  
  output$plot1 <- renderPlot({hist(data1(),
           main = paste("Distribution of", input$var),
           xlab = input$var,
           col = "pink",
           border = "black",
           freq=T)
    }
  )
  
  output$stats <- renderPrint({
    summary(data1())
  })
  
  # TAB 2: Bar Plot 
  data2 <- reactive({
    covid_countries[[input$variable]]
  })
  
  output$varname2 <- renderText({
    paste("Horizontal Bar Plot of:", input$variable," for the top 10 countries")
  })
  
  output$plot2 <- renderPlot({
    x <- sort(data2(),decreasing=TRUE,na.last=TRUE)
    y=c()
    for(i in 1:10)
    y[i]=covid_countries$country_other[which(data2()==x[i])]
    df=data.frame(value=x[1:10],country=y)
          ggplot(df, aes(x = reorder(country, value), y = value, fill = country)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(
    title = "Top 10 Countries by the Selected Variable",
    x = "Country",
    y = "Value"
  ) +
  theme_minimal() +
  theme(legend.position = "none")})

  output$table2 <- renderTable({x <- sort(data2(),decreasing=TRUE,na.last=TRUE)
    country=c()
    for(i in 1:10)
    country[i]=covid_countries$country_other[which(data2()==x[i])]
    df=data.frame(country,x[1:10])
    names(df)=c("country",input$variable)
    print(df)}
   )
  
  #  TAB 3: Scatterplot
  output$scatter_title <- renderText({
    paste("Scatterplot of", input$yvar, "vs", input$xvar)
  })
  
  output$scatterplot <- renderPlot({
  xvar <- input$xvar
  yvar <- input$yvar
  
  ggplot(covid_countries, aes_string(x = xvar, y = yvar)) +
    geom_point(size = 3, alpha = 0.7) +          
    geom_smooth(method = "lm", se = FALSE , color = "red", linewidth = 1.2) + 
    labs(
      x = xvar,
      y = yvar,
      title = paste("Scatterplot of", yvar, "vs", xvar)
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(face = "bold", hjust = 0.5),
      plot.background = element_rect(fill = "ivory", color = NA)
    )
})

  output$corr <- renderText({paste("The correlation coefficient between ", input$xvar," and ", input$yvar," is ", round(cor(covid_countries[,input$xvar],covid_countries[,input$yvar],use="complete.obs"),2))})

  #TAB 4
     
     coun=reactive({input$country})
     output$countryTitle <- renderText({paste("Data for ",coun())})
     output$countryTable <- renderTable({covid_countries[covid_countries$country_other==coun(),]})
     output$message <- renderText({paste("The NA values indicate that information corresponding to the variable is missing")})
     output$title <- renderText({paste("TABLE DISPLAYING THE RANK OF THE SELECTED COUNTRY FOR THE FOLLOWING : ")})
     output$rank <- renderTable({covid_new <- covid_analysis %>%
       mutate( r_totcase=rank(-totalcases),r_cfr=rank(-cfr), r_recov=rank(-recovery_rate),r_active= rank(-active_case_rate),r_tests=rank(-tests_per_case))

         df=covid_new[covid_new$country_other==coun(),]
        col2=c(df$r_totcase,df$r_cfr,df$r_recov,df$r_active,df$r_tests)
        col1=c("total cases", "CFR"," Recovery rate","Active case rate","Test rate")
        result=data.frame(variable=col1,rank=col2)
        print(result)
 })


  # TAB 5: About
          
          output$table4 <- renderTable({variable <- c("Country", 
              "TotalCases", 
              "NewCases", 
              "TotalDeaths", 
              "NewDeaths", 
              "TotalRecovered", 
              "ActiveCases", 
              "Serious,Critical", 
              "Tot Cases/1M pop", 
              "Deaths/1M pop", 
              "TotalTests", 
              "Tests/1M pop", 
              "Population")

                 description <- c("Name of the country ",
                 "Total number of confirmed COVID-19 cases",
                 "Number of new cases reported today",
                 "Total number of deaths due to COVID-19",
                 "Number of new deaths reported today",
                 "Total number of recovered patients",
                 "Current number of active COVID-19 cases",
                 "Number of serious or critical cases",
                 "Total cases per 1 million population",
                 "Total deaths per 1 million population",
                 "Total number of tests conducted",
                 "Number of tests per 1 million population",
                 "Estimated population of the country")
             print(data.frame(variable,description))})
           output$method <- renderText({
    paste(
      "1. COVID-19 data was scraped from Worldometers using the 'rvest' package.",
      "2. Column names were standardised to snake_case and empty names were fixed.",
      "3. Unwanted characters like commas and plus signs were removed, and whitespace was trimmed.",
      "4. Numeric columns were converted to the correct type; empty strings became NA (missing values).",
      "5. Non-country and summary rows were excluded.",
      "6. Irrelevant columns such as col1 that had rank numbers were dropped for clarity and better understanding.",
      sep = "\n"
    )
  })
  
  output$eda <- renderTable({data.frame(
  Step = 1:7,
  Method = c(
    "Derived Metrics Creation",
    "Descriptive Statistics",
    "Comparative Rankings",
    "Correlation Analysis",
    "Category-wise Analysis",
    "Outlier Detection",
    "Data Visualization"
  ),
  Description = c(
    "Created CFR, Recovery Rate, Active Case Rate, Tests per Case; grouped by population and testing intensity.",
    "Calculated mean, median, SD, and quartiles for key metrics.",
    "Ranked countries by cases, deaths, CFR, recovered cases and testing rates (total and per capita).",
    "Computed correlation matrix to analyze relationships between variables.",
    "Compared outcome averages across population and testing categories.",
    "Identified statistical outliers in main columns using IQR method.",
    "Plotted summary, ranking, and correlation visuals for interpretation."
  ),
  stringsAsFactors = FALSE
)
})
  output$procedure <- renderText({
  paste(
    "1. A Shiny web application was developed to provide an interactive interface for exploring the data.",
    "2. Users can visualize distributions of numeric variables through histograms and identify top 10 countries via horizontal bar plots.",
    "3. Scatterplots allow users to examine relationships between key variables (e.g., tests vs deaths).",
    "4. The Country Explorer tab provides detailed statistics and ranks for any selected country.",
    "5. The About section summarizes data descriptions, methodology, and the structure of the Shiny app for user understanding.",
    sep = "\n"
  )
})
}

shinyApp(ui = ui, server = server)
