#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

library(shiny)
library(shinyjs)
library(DT)
library(rsconnect)


PWL_data <- "https://raw.githubusercontent.com/ryanvanmanen/WQ-Data/main/NY_Query/PWL_2023/PWL_2023.csv"
CSLAP_data  <- "https://raw.githubusercontent.com/ryanvanmanen/WQ-Data/main/NY_Query/CSLAP/CSLAP_data.csv"

ui <- fluidPage(
  titlePanel("NYS DEC Waterbody Inventory/Priority Waterbodies List"),
  tabsetPanel(
    tabPanel("Waterbody Inventory", 
             mainPanel(
               h4('Updated June 2023'),
               verbatimTextOutput("rowCount1"),
               DTOutput("table1"),
               style = 'width:100%;'
             )
    ),
    tabPanel("CSLAP",
             mainPanel(
               h4('Updated February 2023'),
               verbatimTextOutput("rowCount2"),
               DTOutput("table2"),
               style = 'width:100%;'
             )
    )
  )
)

server <- function(input, output) {
  data1 <- reactive({
    df <- read.csv(PWL_data)
    df$FACT_SHEET <- paste0("<a href='",df$FACT_SHEET,"'", 'target="_blank">',df$FACT_SHEET,"</a>")
    df$HMW <- paste0("<a href='",df$HMW,"'", 'target="_blank">',df$HMW,"</a>")
    
    return(df)
  })
  
  data2 <- reactive({
    df <- read.csv(CSLAP_data)
    return(df)
  })
  
  output$rowCount1 <- renderText({
    req(data1())
    paste("Total Assessment Units: ", nrow(data1()))
  })
  
  output$table1 <- renderDT({
    datatable(data1(),
              options = list(searchHighlight = TRUE, searching = TRUE,
                             scrollX =TRUE), 
              filter="top",escape = FALSE, class = 'cell-border stripe')
  })
  
  output$rowCount2 <- renderText({
    req(data2())
    paste("Total CSLAP Lakes: ", nrow(data2()))
  })
  
  output$table2 <- renderDT({
    datatable(data2(), options = list(searchHighlight = TRUE, searching = TRUE,
                                      width = "100%",scrollX=TRUE, autoWidth = TRUE, fixedColumns=TRUE),
              filter="top",class = 'cell-border stripe')
  })
}

shinyApp(ui, server)
