library(shiny)
library(shinyjs)
library(DT)
library(rsconnect)
library(googlesheets4)
library(leaflet)
library(leaflet.extras)

gs4_deauth()

PWL_data <- read_sheet("https://docs.google.com/spreadsheets/d/1Z58bVNeNLI1F7NRNCjrDATgzPfK5H03JXNKLTypTzjs/edit#gid=0",
                       na = "NA", range="Sheet1",col_names = TRUE)
Org_data <- read_sheet("https://docs.google.com/spreadsheets/d/1Z58bVNeNLI1F7NRNCjrDATgzPfK5H03JXNKLTypTzjs/edit#gid=0",
                       na = "NA", range="Sheet2",col_names = TRUE)
Lake_location <-read_sheet("https://docs.google.com/spreadsheets/d/1Z58bVNeNLI1F7NRNCjrDATgzPfK5H03JXNKLTypTzjs/edit#gid=0",
                           na = "NA", range="Sheet3",col_names = TRUE)
Stream_location <-read_sheet("https://docs.google.com/spreadsheets/d/1Z58bVNeNLI1F7NRNCjrDATgzPfK5H03JXNKLTypTzjs/edit#gid=0",
                             na = "NA", range="Sheet4",col_names = TRUE)

ui <- fluidPage(
  titlePanel("NYS Waterbodies Query"),
  tabsetPanel(
    tabPanel("Waterbodies Inventory", 
             mainPanel(
               h5(a("Waterbody Inventory Data Source", href="https://data.gis.ny.gov/maps/fe6e369f89444618920a5b49f603e34a/about")),
               h5(a("WQS Data Source", href="https://data.ny.gov/Energy-Environment/Waterbody-Classifications/8xz8-5u5u")),
               h5("WQS: ",a("Westlaw",href="https://govt.westlaw.com/nycrr/Browse/Home/NewYork/NewYorkCodesRulesandRegulations?guid=I0b616fc0b5a111dda0a4e17826ebc834&originationContext=documenttoc&transitionType=Default&contextData=(sc.Default)")),
               verbatimTextOutput("rowCount1"),
               downloadButton("downloadTable1", "Download selected rows as CSV"),
               DTOutput("table1"),
               style = 'width:100%;'
             )),
             # tabPanel("Watershed Organizations",
             #          mainPanel(
             #            h5("Watershed Organizations"),
             #            DTOutput("table2"),
             #            style = 'width:100%;'
             #          ))
  ))
    ##tabPanel("Monitoring Locations",
    ##         mainPanel(
    ##           h5("Monitoring Locations"),
    ##          leafletOutput("map"),
    ##           style = 'width:100%;', 
    ##           style ='height:125%;'
    ##         )),
    ##))

server <- function(input, output) {
  data1 <- reactive({
    df <- PWL_data
    df$FACT_SHEET <- paste0("<a href='",df$FACT_SHEET,"'", 'target="_blank">',df$FACT_SHEET,"</a>")
    df$HMW <- paste0("<a href='",df$HMW,"'", 'target="_blank">',df$HMW,"</a>")
    df$Monitoring_Data <- paste0("<a href='",df$Monitoring_Data,"'", 'target="_blank">',df$Monitoring_Data,"</a>")
    df$USGS <- paste0("<a href='",df$USGS,"'", 'target="_blank">',df$USGS,"</a>")
    #df$CSLAP <- paste0("<a href='",df$CSLAP,"'", 'target="_blank">',df$CSLAP,"</a>")
    return(df)
  })
  
  data2 <- reactive({
    df <- Org_data
    df$Link <- paste0("<a href='",df$Link,"'", 'target="_blank">',df$Link,"</a>")
    return(df)
  })
  data3 <- reactive({
    df <- Lake_location
    return(df)
  })
  data4 <- reactive({
    df <- Stream_location
    return(df)
  })
  
  output$rowCount1 <- renderText({
    req(data1())
    paste("Total Assessment Units: ", nrow(data1()))
  })
  
  output$table1 <- renderDT({
    datatable(data1(),
              options = list(searchHighlight = TRUE, searching = TRUE,
                             scrollX =TRUE,rowCallback = JS(
                               "function(row, data, displayNum, displayIndex, dataIndex) {
         var api = this.api();$(row).attr('data-row-index', dataIndex);}")),rownames = FALSE, 
              filter="top",escape = FALSE, class = 'cell-border stripe')
  })
  # output$table2 <- renderDT({
  #   datatable(data2(),
  #             options = list(searchHighlight = TRUE, searching = TRUE,
  #                            scrollX =TRUE),rownames = FALSE, 
  #             filter="top",escape = FALSE, class = 'cell-border stripe')
  # })
  
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

  ##output$map <- renderLeaflet({
  ##  leaflet() %>%
  ##    setView(lng = -75.849, lat = 42.7085, zoom = 6.8) %>%
  ##    addProviderTiles(providers$Esri.WorldTopoMap) %>%
  ##    addCircleMarkers(data=data3(),
  ##                     lng=data3()$LONGITUDE, lat=data3()$LATITUDE,
  ##                     popup = ~paste("Lake Name: ",data3()$LAKE_NAME, "<br>LAKE ID: ",data3()$LAKE_ID,
  ##                                    "<br>PWL: ", data3()$PWL_ID,"<br>Class: ", data3()$CLASS,
  ##                                    "<br>County: ", data3()$LAKE_COUNTIES),
  ##                     radius = 2,
  ##                     color = "#6B9B6B",
  ##                     fillOpacity = 0.4, group = "Lake Sites")%>%
    
  ##    addCircleMarkers(data=data4(),
  ##                   lng=data4()$LONGITUDE, lat=data4()$LATITUDE,
  ##                   popup = ~paste("Stream Name: ",data4()$STREAM_NAME, "<br>LAKE ID: ",data4()$STREAM_ID,
  ##                                "<br>PWL: ", data4()$PWL_ID,
  ##                                  "<br>Description: ", data4()$description),
  ##                   radius = 2,
  ##                   color = "#FECB00",
  ##                   fillOpacity = 0.8, group="Stream Sites") %>%
  ##  addLayersControl(
  ##    overlayGroups = c("Lake Sites", "Stream Sites"),
  ##    options = layersControlOptions(collapsed = FALSE)
  ##  )%>%
      
   ##   addSearchFeatures(
   ##     targetGroups = c("Lake Sites", "Stream Sites"), # group should match addMarkers() group
   ##     options = searchFeaturesOptions(
   ##       zoom=12, openPopup = TRUE, firstTipSubmit = TRUE,
  ##      autoCollapse = TRUE, hideMarkerOnCollapse = TRUE
    ##    )
    ##  )
      
  ##})
  
}

shinyApp(ui, server)