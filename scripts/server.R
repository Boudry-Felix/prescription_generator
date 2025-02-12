template_base64 <- reactiveVal(NULL)

observeEvent(input$template, {
  req(input$template)
  template_path <- input$template$datapath

  if (grepl("\\.pdf$", template_path, ignore.case = TRUE)) {
    pdf_images <- pdf_convert(template_path, format = "png", dpi = 150)
    encoded_images <- lapply(pdf_images, function(img) {
      base64enc::dataURI(file = img, mime = "image/png")
    })
    template_base64(encoded_images)
  } else {
    encoded_image <- base64enc::dataURI(file = template_path, mime = "image/png")
    template_base64(list(encoded_image))
  }
})

output$template_display <- renderUI({
  req(template_base64())

  tags$div(
    id = "template_container", # Parent container for template and fields
    style = paste0(
      "position: relative;", # Ensure children (draggable fields) are positioned relative to this
      "width: 600px;",
      "height: 850px;", # Adjust based on template size
      "background-image: url(", template_base64(), ");",
      "background-size: contain;",
      "background-repeat: no-repeat;",
      "background-position: center;",
      "border: 1px solid black;" # Optional for debugging
    ),

    # Draggable fields inside the same container
    jqui_draggable(div(id = "name_field", "Name", class = "draggable-field", style = "top: 50px; left: 50px;")),
    jqui_draggable(div(id = "surname_field", "Surname", class = "draggable-field", style = "top: 100px; left: 50px;")),
    jqui_draggable(div(id = "dob_field", "Date of Birth", class = "draggable-field", style = "top: 150px; left: 50px;")),
    jqui_draggable(div(id = "text_field", "Text", class = "draggable-field", style = "top: 200px; left: 50px;")),
    jqui_draggable(div(id = "signature_field", "Signature", class = "draggable-field", style = "top: 250px; left: 50px;"))
  )
})

coords <- reactiveValues(
  name_field = NULL,
  surname_field = NULL,
  dob_field = NULL,
  signature_field = NULL,
  text_field = NULL
)

observe({
  coords$name_field <- input$name_field_position
  coords$surname_field <- input$surname_field_position
  coords$dob_field <- input$dob_field_position
  coords$signature_field <- input$signature_field_position
  coords$text_field <- input$text_field_position
})

observeEvent(input$generate, {
  req(input$template, input$patients, input$signature, input$personal_text)

  patients <- read.csv(input$patients$datapath)

  field_positions <- list(
    name = paste0("+", coords$name_field$left * 1.4, "+", coords$name_field$top * 1.4),
    surname = paste0("+", coords$surname_field$left * 1.4, "+", coords$surname_field$top * 1.4),
    dob = paste0("+", coords$dob_field$left * 1.4, "+", coords$dob_field$top * 1.4),
    signature = paste0("+", coords$signature_field$left * 1.4, "+", coords$signature_field$top * 1.4),
    text = paste0("+", coords$text_field$left * 1.4, "+", coords$text_field$top * 1.4)
  )

  pdf_files <- lapply(1:nrow(patients), function(i) {
    patient <- patients[i, ]
    output_file <- tempfile(fileext = ".pdf")

    template_image <- image_read(input$template$datapath, density = "100x100")
    template_image <- image_annotate(template_image, text = patient$name, location = field_positions$name, size = 30)
    template_image <- image_annotate(template_image, text = patient$surname, location = field_positions$surname, size = 30)
    template_image <- image_annotate(template_image, text = patient$date, location = field_positions$dob, size = 30)
    template_image <- image_annotate(template_image, text = input$personal_text, location = field_positions$text, size = 30)
    signature_image <- image_read(input$signature$datapath)
    template_image <- image_composite(template_image, signature_image, offset = field_positions$signature)

    image_write(template_image, path = output_file, format = "pdf", density = "100x100")
    return(output_file)
  })

  if (input$output_type == "single") {
    combined_pdf_path <- tempfile(fileext = ".pdf")
    pdf_combine(input = pdf_files, output = combined_pdf_path)
    output_files <- list(combined_pdf_path)
  } else {
    output_files <- pdf_files
  }

  output$download <- downloadHandler(
    filename = function() {
      if (input$output_type == "single") {
        "all_prescriptions.pdf"
      } else {
        "prescriptions.zip"
      }
    },
    content = function(file) {
      if (input$output_type == "single") {
        file.copy(output_files[[1]], file)
      } else {
        zip(zipfile = file, files = output_files, flags = "-j")
      }
    }
  )
})
