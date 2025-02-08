template_base64 <- reactiveVal(NULL)

  observeEvent(input$template, {
    req(input$template)
    template_path <- input$template$datapath

    if (grepl("\\.pdf$", template_path, ignore.case = TRUE)) {
      pdf_images <- pdf_convert(template_path, format = "png", dpi = 72)
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
    img_tags <- lapply(template_base64(), function(img) {
      tags$img(src = img, style = "width: 100%; height: auto;")
    })
    do.call(tagList, img_tags)
  })

  observe({
    jqui_draggable("#name_field")
    jqui_draggable("#surname_field")
    jqui_draggable("#dob_field")
    jqui_draggable("#signature_field")
  })

  # get_position <- function(id) {
  #   pos <- input[[paste0(id, "_pos")]]
  #   list(left = pos$left, top = pos$top)
  # }
  
  observeEvent(input$generate, {
    req(input$template, input$patients, input$signature, input$personal_text)

    patients <- read.csv(input$patients$datapath)

    # name_pos <- get_position("#name_field")
    # surname_pos <- get_position("#surname_field")
    # dob_pos <- get_position("#dob_field")
    # signature_pos <- get_position("#signature_field")

    # field_positions <- list(
    #   name = paste0("+", name_pos$left, "+", name_pos$top),
    #   surname = paste0("+", surname_pos$left, "+", surname_pos$top),
    #   dob = paste0("+", dob_pos$left, "+", dob_pos$top),
    #   signature = paste0("+", signature_pos$left, "+", signature_pos$top)
    # )
    
    pdf_files <- lapply(1:nrow(patients), function(i) {
      patient <- patients[i, ]
      output_file <- tempfile(fileext = ".pdf")

      template_image <- image_read(input$template$datapath)
      template_image <- image_annotate(template_image, text = patient$name, location = "+100+100", size = 20)
      template_image <- image_annotate(template_image, text = patient$surname, location = "+100+200", size = 20)
      template_image <- image_annotate(template_image, text = patient$date, location = "+100+300", size = 20)
      template_image <- image_annotate(template_image, text = input$personal_text, location = "+100+400", size = 20)
      signature_image <- image_read(input$signature$datapath)
      template_image <- image_composite(template_image, signature_image, offset = "+100+500")

      image_write(template_image, path = output_file, format = "pdf")
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