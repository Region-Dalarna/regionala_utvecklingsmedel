shinyServer(function(input, output, session) {

  output$stapeldiagram <- renderPlot({
    data_trans %>%
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

#shinyServer(function(input, output, session) {

  # Filtrera data baserat på användarens val
  #data_filtered <- reactive({
   # data_trans %>%
    #  filter(beslut_ar == input$valt_ar)
  #})
#})
