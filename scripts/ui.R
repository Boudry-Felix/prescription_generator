fluidPage(
  titlePanel("Prescription Generator"),
  sidebarLayout(
    sidebarPanel(
      fileInput("template", "Choose Prescription Template (Image/PDF)", accept = c("image/png", "image/jpeg", "application/pdf")),
      fileInput("patients", "Choose Patient List (CSV)", accept = ".csv"),
      fileInput("signature", "Choose Signature Image (PNG/JPG)", accept = c("image/png", "image/jpeg")),
      textInput("personal_text", "Enter Personal Text", value = ""),
      radioButtons("output_type", "Output Type", choices = list("Individual PDFs" = "individual", "Single PDF" = "single")),
      actionButton("generate", "Generate Prescriptions"),
      verbatimTextOutput("coords")
    ),
    mainPanel(
      uiOutput("template_display"),
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
