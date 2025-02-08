fluidPage(
  titlePanel("Prescription Generator"),
  sidebarLayout(
    sidebarPanel(
      fileInput("template", "Choose Prescription Template (Image/PDF)", accept = c("image/png", "image/jpeg", "application/pdf")),
      fileInput("patients", "Choose Patient List (CSV)", accept = ".csv"),
      fileInput("signature", "Choose Signature Image (PNG/JPG)", accept = c("image/png", "image/jpeg")),
      textInput("personal_text", "Enter Personal Text", value = ""),
      radioButtons("output_type", "Output Type", choices = list("Individual PDFs" = "individual", "Single PDF" = "single")),
      actionButton("generate", "Generate Prescriptions")
    ),
    mainPanel(
      uiOutput("template_display"),
      div(id = "fields_container", style = "position: relative; width: 100%; height: 500px; border: 1px solid #ccc;",
          div(id = "name_field", "Name", class = "draggable-field", style = "top: 50px; left: 50px;"),
          div(id = "surname_field", "Surname", class = "draggable-field", style = "top: 100px; left: 50px;"),
          div(id = "dob_field", "Date of Birth", class = "draggable-field", style = "top: 150px; left: 50px;"),
          div(id = "signature_field", "Signature", class = "draggable-field", style = "top: 200px; left: 50px;")
      ),
      downloadButton("download", "Download Prescriptions")
    )
  ),

# Add custom CSS for draggable fields
tags$head(tags$style(HTML("
.draggable-field {
  border: 1px solid #ccc;
  padding: 5px;
  cursor: move;
  background-color: #f9f9f9;
  position: absolute;
}
")))
)

