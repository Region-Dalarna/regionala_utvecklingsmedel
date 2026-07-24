shinyServer(function(input, output, session) {

# FLIKEN Samlade 1:1-medel

  output$stapeldiagram_ar_stod <- renderPlot({
    req(input$valda_stodtyper, input$valda_ar)
    data_trans %>%
      filter(stodtyp %in% input$valda_stodtyper) %>%
      group_by(beslut_ar, stodtyp) %>%
      summarise(summa = sum(beviljat_belopp, na.rm = TRUE), .groups = "drop") %>%
      ggplot(aes(x = factor(beslut_ar), y = summa, fill = stodtyp)) +
      geom_col(position = "dodge") +
      scale_fill_manual(
        values = c("PROJ" = "steelblue",
                   "FTG"  = "darkorange",
                   "KS"   = "forestgreen"),
        labels = c("PROJ" = "Projektmedel",
                   "FTG"  = "Företagsstöd",
                   "KS"   = "Kommersiell service")
      ) +
      labs(
        title = "Beviljat belopp per år",
        x = "År",
        y = "Summa beviljat belopp (kr)",
        fill = "Stödtyp"
    ) +
    theme_minimal()
  })

# FLIKEN PROJEKTMEDEL

  #Filtrerat dataset för projektstöd
  proj_data <- reactive({
    data_trans %>%
      filter(stodtyp == "PROJ",
             beslut_ar %in% input$proj_ar)
  })

  # Diagram beviljade och utbetalada medel
  output$proj_ar_diagram <- renderPlot({

    if (input$proj_matt == "belopp") {
      plot_data <- proj_data() %>%
        group_by(beslut_ar) %>%
        summarise(varde = sum(beviljat_belopp, na.rm = TRUE))
      y_label <- "Summa beviljat belopp (kr)"

    } else {
      plot_data <- proj_data() %>%
        group_by(beslut_ar) %>%
        summarise(varde = n_distinct(arende))
      y_label <- "Antal ärenden"

    }

    plot_data %>%
      ggplot(aes(x = beslut_ar, y = varde, fill = beslut_ar)) +
      geom_col(fill = "steelblue") +
      labs(
        title = "Projektmedel per kalenderår",
        x = "År",
        y = y_label
      ) +
      theme_minimal() +
      theme(legend.position = "none")
    })

# FLIKEN FÖRETAGSSTÖD

  #Filtrerat dataset för företagsstöd
  ftg_data <- reactive({
    data_trans %>%
      filter(stodtyp == "FTG",
             beslut_ar %in% input$ftg_ar)
  })

# Diagram könsfördelning VD
output$ftg_kon_diagram <- renderPlot({

  if (input$ftg_matt == "belopp") {
    plot_data <- ftg_data() %>%
      group_by(vd_kon_ren) %>%
      summarise(varde = sum(beviljat_belopp, na.rm = TRUE))
    y_label <- "Summa beviljat belopp (kr)"

  } else if (input$ftg_matt == "antal") {
    plot_data <- ftg_data() %>%
      group_by(vd_kon_ren) %>%
      summarise(varde = n_distinct(arende))
    y_label <- "Antal ärenden"

    } else {
  plot_data <- ftg_data() %>%
    group_by(vd_kon_ren) %>%
    summarise(varde = sum(utbet_belopp, na.rm = TRUE))
  y_label <- "Utbetalt belopp"
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
    theme_minimal() +
    theme(legend.position = "none")  # tar bort legenden
})

# Branschfördelning (obs! branscherna är sammanslagna och översatta SNI 2007 + 2025)
output$ftg_bransch_diagram <- renderPlot({

  if (input$ftg_matt == "belopp") {
    plot_data <- ftg_data() %>%
      group_by(bransch_avd_2025) %>%
      summarise(varde = sum(beviljat_belopp, na.rm = TRUE))
    y_label <- "Summa beviljat belopp (kr)"

  } else if (input$ftg_matt == "antal") {
    plot_data <- ftg_data() %>%
      group_by(bransch_avd_2025) %>%
      summarise(varde = n_distinct(arende))
    y_label <- "Antal ärenden"

  } else {
  plot_data <- ftg_data() %>%
    group_by(bransch_avd_2025) %>%
    summarise(varde = sum(utbet_belopp, na.rm = TRUE))
  y_label <- "Utbetalt belopp"
}
  plot_data %>%
    mutate(bransch_kort = str_trunc(bransch_avd_2025, width = 20, ellipsis = "...")) %>%
    ggplot(aes(x = reorder(bransch_kort, varde), y = varde, fill = bransch_kort)) +
    geom_col() +
    coord_flip() +
    labs(
      title = "Fördelning per bransch",
      x = "Bransch",
      y = y_label
    ) +
    theme_minimal() +
    theme(legend.position = "none")
})

# Kommunfördelning
output$ftg_kommun_diagram <- renderPlot({

  if (input$ftg_matt == "belopp") {
    plot_data <- ftg_data() %>%
      group_by(arbetsstalle) %>%
      summarise(varde = sum(beviljat_belopp, na.rm = TRUE))
    y_label <- "Summa beviljat belopp (kr)"

  } else if (input$ftg_matt == "antal") {
    plot_data <- ftg_data() %>%
      group_by(arbetsstalle) %>%
      summarise(varde = n_distinct(arende))
    y_label <- "Antal ärenden"

  }  else {
  plot_data <- ftg_data() %>%
    group_by(arbetsstalle) %>%
    summarise(varde = sum(utbet_belopp, na.rm = TRUE))
  y_label <- "Utbetalt belopp"
}
  plot_data %>%
    ggplot(aes(x = reorder(arbetsstalle, varde), y = varde, fill = arbetsstalle)) +
    geom_col() +
    coord_flip() +
    labs(
      title = "Fördelning per kommun",
      x = "Kommun",
      y = y_label
    ) +
    theme_minimal() +
    theme(legend.position = "none")
})

# Fördelning lokal klassificering 1
output$ftg_lokal_1_diagram <- renderPlot({

  if (input$ftg_matt == "belopp") {
    plot_data <- ftg_data() %>%
      group_by(lokal_1) %>%
      summarise(varde = sum(beviljat_belopp, na.rm = TRUE))
    y_label <- "Summa beviljat belopp (kr)"

  } else if (input$ftg_matt == "antal") {
    plot_data <- ftg_data() %>%
      group_by(lokal_1) %>%
      summarise(varde = n_distinct(arende))
    y_label <- "Antal ärenden"

    } else {
  plot_data <- ftg_data() %>%
    group_by(lokal_1) %>%
    summarise(varde = sum(utbet_belopp, na.rm = TRUE))
  y_label <- "Utbetalt belopp"
}
  plot_data %>%
    ggplot(aes(x = reorder(lokal_1, varde), y = varde, fill = lokal_1)) +
    geom_col() +
    coord_flip() +
    labs(
      title = "Fördelning klassificering 1",
      x = "Klassificering",
      y = y_label
    ) +
    theme_minimal() +
    theme(legend.position = "none")
})



# Filtrera för kommersiell service
ks_data <- reactive({
  data_trans %>%
    filter(stodtyp == "KS",
           beslut_ar %in% input$ks_ar)
})

# Kommunfördelning
output$ks_kommun_diagram <- renderPlot({

  if (input$ks_matt == "belopp") {
    plot_data <- ks_data() %>%
      group_by(arbetsstalle) %>%
      summarise(varde = sum(beviljat_belopp, na.rm = TRUE))
    y_label <- "Summa beviljat belopp (kr)"

  } else if (input$ks_matt == "antal"){
    plot_data <- ks_data() %>%
      group_by(arbetsstalle) %>%
      summarise(varde = n_distinct(arende))
    y_label <- "Antal ärenden"

    } else {
    plot_data <- ks_data() %>%
      group_by(arbetsstalle) %>%
      summarise(varde = sum(utbet_belopp, na.rm = TRUE))
    y_label <- "Utbetalt belopp"
  }
  plot_data %>%
    ggplot(aes(x = reorder(arbetsstalle, varde), y = varde, fill = arbetsstalle)) +
    geom_col() +
    coord_flip() +
    labs(
      title = "Fördelning per kommun",
      x = "Kommun",
      y = y_label
    ) +
    theme_minimal() +
    theme(legend.position = "none")
} )

} )

