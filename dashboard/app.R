# dashboard/app.R
# Purpose: Interactive Shiny dashboard for campaign monitoring and recommendations
# Features: KPI tracking, segment efficiency view, budget recommendations, model insights

library(shiny)
library(tidyverse)
library(dplyr)
library(ggplot2)
library(plotly)

# Load processed data
ads_data <- read_csv("../data/processed/ads_modeling_table.csv")
recommendations <- read_csv("../data/processed/budget_reallocation_recommendations.csv")

# UI
ui <- fluidPage(
  titlePanel("Meta Ads Campaign Performance Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      h3("Filters"),
      selectInput("age_filter", "Select Age Group:", 
                  choices = c("All", unique(ads_data$age)), 
                  selected = "All"),
      selectInput("gender_filter", "Select Gender:", 
                  choices = c("All", unique(ads_data$gender)), 
                  selected = "All"),
      checkboxInput("show_low_efficiency", "Highlight Low Efficiency", FALSE)
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("KPI Overview",
          h3("Overall Campaign Metrics"),
          fluidRow(
            column(3, h4("Total Spend"), textOutput("total_spend")),
            column(3, h4("Total Conversions"), textOutput("total_conversions")),
            column(3, h4("Avg CPA"), textOutput("avg_cpa")),
            column(3, h4("Overall CTR"), textOutput("overall_ctr"))
          ),
          hr(),
          plotlyOutput("spend_vs_conversions_plot")
        ),
        
        tabPanel("Segment Efficiency",
          h3("Segment Performance Analysis"),
          dataTableOutput("segment_table"),
          hr(),
          plotlyOutput("efficiency_plot")
        ),
        
        tabPanel("Budget Recommendations",
          h3("Reallocation Strategy"),
          p("Current allocation by efficiency tier:"),
          plotlyOutput("reallocation_plot"),
          hr(),
          p("Top segments to reduce spend:"),
          dataTableOutput("reduce_table"),
          hr(),
          p("Top segments to increase spend:"),
          dataTableOutput("increase_table")
        ),
        
        tabPanel("Demographics Analysis",
          h3("Performance by Demographics"),
          plotlyOutput("demo_plot"),
          hr(),
          dataTableOutput("demo_table")
        )
      )
    )
  )
)

# Server
server <- function(input, output) {
  
  # Filtered data
  filtered_data <- reactive({
    df <- ads_data
    if (input$age_filter != "All") {
      df <- df %>% filter(age == input$age_filter)
    }
    if (input$gender_filter != "All") {
      df <- df %>% filter(gender == input$gender_filter)
    }
    df
  })
  
  # KPI outputs
  output$total_spend <- renderText({
    paste("$", round(sum(filtered_data()$Spent, na.rm = TRUE), 2))
  })
  
  output$total_conversions <- renderText({
    paste(round(sum(filtered_data()$Approved_Conversion, na.rm = TRUE)))
  })
  
  output$avg_cpa <- renderText({
    spend <- sum(filtered_data()$Spent, na.rm = TRUE)
    convs <- sum(filtered_data()$Approved_Conversion, na.rm = TRUE)
    paste("$", round(spend / convs, 2))
  })
  
  output$overall_ctr <- renderText({
    clicks <- sum(filtered_data()$Clicks, na.rm = TRUE)
    impr <- sum(filtered_data()$Impressions, na.rm = TRUE)
    paste(round((clicks / impr) * 100, 2), "%")
  })
  
  # Plots
  output$spend_vs_conversions_plot <- renderPlotly({
    p <- filtered_data() %>%
      ggplot(aes(x = Spent, y = Approved_Conversion, color = age)) +
      geom_point(alpha = 0.6) +
      facet_wrap(~gender) +
      labs(title = "Spend vs Conversions", x = "Spend", y = "Conversions") +
      theme_minimal()
    ggplotly(p)
  })
  
  # Segment table
  output$segment_table <- renderDataTable({
    filtered_data() %>%
      group_by(interest) %>%
      summarise(
        Ads = n(),
        Spend = round(sum(Spent), 2),
        Conversions = sum(Approved_Conversion),
        CPA = round(mean(cpa), 2),
        CTR = round(mean(ctr), 4),
        .groups = "drop"
      ) %>%
      arrange(desc(Conversions))
  })
  
  # Efficiency plot
  output$efficiency_plot <- renderPlotly({
    p <- filtered_data() %>%
      group_by(interest) %>%
      summarise(Avg_CPA = mean(cpa), .groups = "drop") %>%
      arrange(Avg_CPA) %>%
      head(10) %>%
      ggplot(aes(x = reorder(interest, Avg_CPA), y = Avg_CPA)) +
      geom_col(fill = "steelblue") +
      coord_flip() +
      labs(title = "Top 10 Interests by CPA", x = "Interest", y = "CPA") +
      theme_minimal()
    ggplotly(p)
  })
  
  # Demographics table
  output$demo_table <- renderDataTable({
    filtered_data() %>%
      group_by(age, gender) %>%
      summarise(
        Ads = n(),
        Spend = round(sum(Spent), 2),
        Conversions = sum(Approved_Conversion),
        CPA = round(mean(cpa), 2),
        .groups = "drop"
      )
  })
  
  # Demographics plot
  output$demo_plot <- renderPlotly({
    p <- filtered_data() %>%
      group_by(age, gender) %>%
      summarise(
        Avg_CPA = mean(cpa),
        Total_Conversions = sum(Approved_Conversion),
        .groups = "drop"
      ) %>%
      ggplot(aes(x = age, y = Avg_CPA, fill = gender)) +
      geom_col(position = "dodge") +
      labs(title = "CPA by Demographics", x = "Age", y = "CPA", fill = "Gender") +
      theme_minimal()
    ggplotly(p)
  })
  
  # Reallocation plot
  output$reallocation_plot <- renderPlotly({
    tier_data <- recommendations %>%
      group_by(efficiency_tier) %>%
      summarise(
        Current = sum(Total_Spend),
        Proposed = sum(new_spend),
        .groups = "drop"
      ) %>%
      pivot_longer(-efficiency_tier, names_to = "Scenario", values_to = "Spend")
    
    p <- tier_data %>%
      ggplot(aes(x = efficiency_tier, y = Spend, fill = Scenario)) +
      geom_col(position = "dodge") +
      labs(title = "Budget Reallocation", x = "Tier", y = "Spend", fill = "Scenario") +
      theme_minimal()
    ggplotly(p)
  })
  
  # Reduce/Increase tables
  output$reduce_table <- renderDataTable({
    recommendations %>%
      filter(efficiency_tier == "LOW") %>%
      arrange(desc(Total_Spend)) %>%
      head(5) %>%
      select(interest, age, gender, Total_Spend, Avg_CPA)
  })
  
  output$increase_table <- renderDataTable({
    recommendations %>%
      filter(efficiency_tier == "HIGH") %>%
      arrange(Avg_CPA) %>%
      head(5) %>%
      select(interest, age, gender, Total_Spend, Avg_CPA)
  })
}

# Run app
shinyApp(ui, server)
