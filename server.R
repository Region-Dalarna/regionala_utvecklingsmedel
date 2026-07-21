shinyServer(function(input, output, session) {

  output$stapeldiagram <- renderPlot({
    data_trans %>%
      filter(stodtyp %in% input$valda_stodtyper) %>%
      group_by(beslut_ar) %>%
      summarise(summa = sum(beviljat_belopp, na.rm = TRUE)) %>%
      ggplot(aes(x = factor(beslut_ar), y = summa)) +
      geom_col(fill = "steelblue") +
      labs(
        title = "Beviljat belopp per år",
        x = "År",
        y = "Summa beviljat belopp (kr)"
      ) +
      theme_minimal()
  })
})


# Filtrerat dataset för företagsstöd
ftg_data <- reactive({
  df <- data_trans %>% filter(stodtyp == "FTG")

  if (input$ftg_ar != "Alla år") {
    df <- df %>% filter(beslut_ar == input$ftg_ar)
  }
  df
})

# Diagram könsfördelning VD
output$ftg_kon_diagram <- renderPlot({

  if (input$ftg_matt == "belopp") {
    plot_data <- ftg_data() %>%
      group_by(vd_kon) %>%
      summarise(varde = sum(beviljat_belopp, na.rm = TRUE))
    y_label <- "Summa beviljat belopp (kr)"

  } else {
    plot_data <- ftg_data() %>%
      group_by(vd_kon) %>%
      summarise(varde = n_distinct(arende))
    y_label <- "Antal ärenden"
  }

  plot_data %>%
    ggplot(aes(x = vd_kon_ren, y = varde, fill = vd_kon_ren)) +
    geom_col() +
    labs(
      title = "Könsfördelning på VD-posten",
      x = "Kön",
      y = y_label,
      fill = "Kön"
    ) +
    theme_minimal()
})


#shinyServer(function(input, output, session) {

  # Filtrera data baserat på användarens val
  #data_filtered <- reactive({
   # data_trans %>%
    #  filter(beslut_ar == input$valt_ar)
  #})
#})
