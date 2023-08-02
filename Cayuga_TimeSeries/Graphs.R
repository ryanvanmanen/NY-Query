library(plotly)

samples <- read.csv('C:/Users/rvanmane/OneDrive - Environmental Protection Agency (EPA)/Documents/Cayuga Lake/Cayuga_TimeSeries/TP-MC_data.csv')

fig <- plot_ly(samples, type = 'scatter', mode='markers')%>%
  add_trace(x = ~Date, y = ~MC, name = "Microcystin (ug/L)")%>%
  add_trace(x = ~Date, y = ~TP, name = "TP (ug/L)")%>%
  layout(showlegend = F)
fig <- fig %>%
  layout(
    xaxis = list(zerolinecolor = '#ffff',
                 zerolinewidth = 2,
                 gridcolor = 'ffff'),
    yaxis = list(zerolinecolor = '#ffff',
                 zerolinewidth = 1,
                 gridcolor = 'ffff', title = "Concentration (ug/L)"),
    plot_bgcolor='#e5ecf6', width = 900)


fig
