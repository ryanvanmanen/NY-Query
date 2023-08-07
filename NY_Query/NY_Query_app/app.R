#
# This tool displays waterbody data and metadata from a few NYS sources. 
# This is for internal EPA only.
#
#

library(shiny)
library(shinyjs)
library(DT)
library(rsconnect)


PWL_data <- "https://raw.githubusercontent.com/ryanvanmanen/WQ-Data/main/NY_Query/Data/PWL_2023/PWL_2023.csv"
#CSLAP_data  <- "https://raw.githubusercontent.com/ryanvanmanen/WQ-Data/main/NY_Query/Data/CSLAP/CSLAP_data.csv"
#WQS_data <- "https://raw.githubusercontent.com/ryanvanmanen/WQ-Data/main/NY_Query/Data/Waterbody_Classifications.csv"

ui <- fluidPage(
  titlePanel("NYS Waterbodies Query"),
  tabsetPanel(
    tabPanel("Waterbodies Inventory", 
             mainPanel(
               h5(a("Waterbody Inventory Data Source", href="https://data.gis.ny.gov/maps/fe6e369f89444618920a5b49f603e34a/about")),
               h5(a("WQS Data Source", href="https://data.ny.gov/Energy-Environment/Waterbody-Classifications/8xz8-5u5u")),
               h5("WQS: ",a("Westlaw",href="https://govt.westlaw.com/nycrr/Browse/Home/NewYork/NewYorkCodesRulesandRegulations?guid=I0b616fc0b5a111dda0a4e17826ebc834&originationContext=documenttoc&transitionType=Default&contextData=(sc.Default)")),
              
               verbatimTextOutput("rowCount1"),
               downloadButton("downloadTable1", "Download Selected Rows"),
               DTOutput("table1"),
               style = 'width:100%;'
             )
    ),
#    tabPanel("CSLAP",
#            mainPanel(
#               h4('Updated February 2023'),
#               verbatimTextOutput("rowCount2"),
#               DTOutput("table2"),
#               style = 'width:100%;'
#             )),
   
))

server <- function(input, output) {
  data1 <- reactive({
    df <- read.csv(PWL_data)
    df$FACT_SHEET <- paste0("<a href='",df$FACT_SHEET,"'", 'target="_blank">',df$FACT_SHEET,"</a>")
    df$HMW <- paste0("<a href='",df$HMW,"'", 'target="_blank">',df$HMW,"</a>")
    return(df)
  })
  
#  data2 <- reactive({
#    df <- read.csv(CSLAP_data)
#    return(df)
#  })
  
  
  output$rowCount1 <- renderText({
    req(data1())
    paste("Total Assessment Units: ", nrow(data1()))
  })
  
  output$table1 <- renderDT({
    datatable(data1(),
              options = list(searchHighlight = TRUE, searching = TRUE,
                             scrollX =TRUE,rowCallback = JS(
                               "function(row, data, displayNum, displayIndex, dataIndex) {
         var api = this.api();$(row).attr('data-row-index', dataIndex);}")), 
         filter="top",escape = FALSE, class = 'cell-border stripe',)
  })
  
  
#  output$rowCount2 <- renderText({
#    req(data2())
#    paste("Total CSLAP Lakes: ", nrow(data2()))
#  })
  
#  output$table2 <- renderDT({
#    datatable(data2(), options = list(searchHighlight = TRUE, searching = TRUE,
#                                      width = "100%",scrollX=TRUE, autoWidth = TRUE, fixedColumns=TRUE),
#              filter="top",class = 'cell-border stripe')
#  })
  
  
  output$downloadTable1 <- downloadHandler(
    filename = function() {
      paste("selected_rows_table1.csv", sep = "")
    },
    
    content = function(file) {
      selected_rows <- as.numeric(input$table1_rows_selected)
      if (length(selected_rows) > 0) {
        selected_data <- data1()[selected_rows, ]
        write.csv(selected_data, file, row.names = FALSE)
      }
    }
  )
}

shinyApp(ui, server)
