library(shiny)
# UI libraries
library(shinyFiles)
library(shinyjqui)
# Server libraries
library(pdftools)
library(magick)
library(rmarkdown)

# Source server and UI scripts
ui <- source(file = "scripts/ui.R", local = TRUE)[1]
server <- function(input, output, session){source(file = "scripts/server.R", local = TRUE)}

# Run app
shinyApp(ui = ui, server = server)
