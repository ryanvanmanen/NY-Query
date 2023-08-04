library(shiny)
library(ggplot2)
library(dplyr)
library(readr)
library(plotly)
library(RColorBrewer)

# Define the user interface
ui <- fluidPage(
  titlePanel("WQ Grapher"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Choose a CSV file"),
      selectInput("x_var", "Select X Variable", ""),
      selectInput("y_var", "Select Y Variable(s)", multiple = TRUE, "")
    ),
    mainPanel(
      plotlyOutput("plot")
    )
  )
)

# Define the server logic
server <- function(input, output, session) {
  data <- reactive({
    req(input$file)
    read_csv(input$file$datapath)
  })
  
  observe({
    updateSelectInput(session, "x_var", choices = names(data()))
    updateSelectInput(session, "y_var", choices = names(data()))
  })
  
  output$plot <- renderPlotly({
    req(input$x_var, input$y_var)
    
    y_vars <- input$y_var
    num_colors <- length(y_vars)
    
    color_palette <- colorRampPalette(brewer.pal(9, "Set1"))
    colors <- color_palette(num_colors)
    
    gg <- ggplot(data(), aes_string(x = input$x_var)) +
      lapply(1:num_colors, function(i) {
        geom_point(aes_string(y = y_vars[i]), color = colors[i])
      }) +
      labs(x = input$x_var, y = "Value", title = "Variable Visualization", subtitle = "hover over data points") +
      scale_color_identity(name = "Y Variable", labels = y_vars)
    
    ggplotly(gg)
  })
}

# Run the app
shinyApp(ui, server)
