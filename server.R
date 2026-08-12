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

  # Diagram beviljade medel och antal ärenden
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
      ggplot(aes(x = factor(beslut_ar), y = varde, fill = factor(beslut_ar))) +
      geom_col(fill = "steelblue") +
      labs(
        title = "Projektmedel per kalenderår",
        x = "År",
        y = y_label
      ) +
      theme_minimal() +
      theme(legend.position = "none")
    })

# Utbetalningar i relation till beslutsår.

  output$proj_kohort_diagram <- renderPlot({
    req(input$proj_ar)

    data_trans %>%
      filter(stodtyp == "PROJ",
             beslut_ar %in% input$proj_ar,
             trans_ar <= year(Sys.Date())) %>%
      group_by(beslut_ar, trans_ar) %>%
      summarise(utbet = sum(utbet_belopp, na.rm = TRUE), .groups = "drop") %>%
      ggplot(aes(x = factor(trans_ar), y = utbet, fill = factor(beslut_ar))) +
      geom_col() +
      labs(
        title = "Utbetalningar per år fördelat efter beslutsår",
        x = "Utbetalningsår",
        y = "Utbetalt belopp (kr)",
        fill = "Beslutsår"
      ) +
      theme_minimal()
  })

# Fördelning utifrån nationella strategins kategorier och resultatkedjor, obs ta bort år 2018 som saknar data.

  output$proj_nat_strat_diagram <- renderPlot({
    req(input$proj_ar)

    if (input$proj_matt == "belopp") {
      plot_data <- proj_data() %>%
        group_by(nat_strat_ren, beslut_ar) %>%
        summarise(varde = sum(beviljat_belopp, na.rm = TRUE), .groups = "drop")
      y_label <- "Summa beviljat belopp (kr)"

    } else if (input$proj_matt == "antal") {
      plot_data <- proj_data() %>%
        group_by(nat_strat_ren, beslut_ar) %>%
        summarise(varde = n_distinct(arende), .groups = "drop")
      y_label <- "Antal ärenden"

    } else {
      plot_data <- proj_data() %>%
        group_by(nat_strat_ren, beslut_ar) %>%
        summarise(varde = sum(utbet_belopp, na.rm = TRUE), .groups = "drop")
      y_label <- "Utbetalt belopp (kr)"
    }

    plot_data %>%
      filter(beslut_ar != 2018, !is.na(nat_strat_ren)) %>%
      mutate(nat_strat_kort = str_trunc(nat_strat_ren, width = 20, ellipsis = "...")) %>%
      ggplot(aes(x = nat_strat_kort, y = varde, fill = factor(beslut_ar))) +
      geom_col(position = "stack") +
      labs(
        title = "Fördelning per nationellt strategiområde",
        x = "Strategiområde",
        y = y_label,
        fill = "Beslutår"
      ) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })


  output$proj_resultatkedja_diagram <- renderPlot({
    req(input$proj_ar)

    if (input$proj_matt == "belopp") {
      plot_data <- proj_data() %>%
        group_by(resultatkedja_ren, beslut_ar) %>%
        summarise(varde = sum(beviljat_belopp, na.rm = TRUE), .groups = "drop")
      y_label <- "Summa beviljat belopp (kr)"

    } else if (input$proj_matt == "antal") {
      plot_data <- proj_data() %>%
        group_by(resultatkedja_ren, beslut_ar) %>%
        summarise(varde = n_distinct(arende), .groups = "drop")
      y_label <- "Antal ärenden"

    } else {
      plot_data <- proj_data() %>%
        group_by(resultatkedja_ren, beslut_ar) %>%
        summarise(varde = sum(utbet_belopp, na.rm = TRUE), .groups = "drop")
      y_label <- "Utbetalt belopp (kr)"
    }

    plot_data %>%
      filter(beslut_ar != 2018, !is.na(resultatkedja_ren)) %>%
      mutate(resultatkedja_kort = str_trunc(resultatkedja_ren, width = 20, ellipsis = "...")) %>%
      ggplot(aes(x = resultatkedja_kort, y = varde, fill = factor(beslut_ar))) +
      geom_col(position = "stack") +
      labs(
        title = "Fördelning per resultatkedja",
        x = "Resultatkedja",
        y = y_label,
        fill = "Beslutår"
      ) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })


  # FLIKEN PROJEKTMEDEL 2

  # Pågående projekt, dynamiskt sökbar
  proj_status_data <- reactive({

    data_trans %>%
      filter(stodtyp == "PROJ",
             !is.na(startdatum),
             !is.na(slutdatum)) %>%
      distinct(projektnamn, startdatum, slutdatum, beslut_ar) %>%
      rowwise() %>%
      mutate(kvartal_lista = list(seq(
        from = as.Date(paste0(year(startdatum), "-",
                              sprintf("%02d", (quarter(startdatum) - 1) * 3 + 1), "-01")),
        to   = as.Date(paste0(year(slutdatum), "-",
                              sprintf("%02d", (quarter(slutdatum) - 1) * 3 + 1), "-01")),
        by   = "quarter"
      ))) %>%
      unnest(kvartal_lista) %>%
      mutate(
        kalender_ar  = factor(year(kvartal_lista)),  # factor istället för numerisk
        kvartal      = paste0("Q", quarter(kvartal_lista)),
        projekt_status = case_when(
          year(startdatum)   == year(kvartal_lista) &
            quarter(startdatum) == quarter(kvartal_lista) ~ "Uppstart",
          year(slutdatum)    == year(kvartal_lista) &
            quarter(slutdatum)  == quarter(kvartal_lista) ~ "Avslutas",
          TRUE ~ "Pågående"
        )
      ) %>%
      select(projektnamn, kalender_ar, kvartal, projekt_status, startdatum, slutdatum)
  })

  output$proj_status_tabell <- renderDT({
    proj_status_data() %>%
      datatable(
        colnames = c("Projektnamn", "År", "Kvartal", "Status", "Startdatum", "Slutdatum"),
        options  = list(pageLength = 15),
        filter   = "top"   # filter i kolumnrubrikerna
      )
  })

  # Beviljade medel per projektägare

  # output$proj_agare_diagram




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

# Utbetalningar i relation till beslutsår.

output$ftg_kohort_diagram <- renderPlot({
  req(input$ftg_ar)

  data_trans %>%
    filter(stodtyp == "FTG",
           beslut_ar %in% input$ftg_ar,
           trans_ar <= year(Sys.Date())) %>%
    group_by(beslut_ar, trans_ar) %>%
    summarise(utbet = sum(utbet_belopp, na.rm = TRUE), .groups = "drop") %>%
    ggplot(aes(x = factor(trans_ar), y = utbet, fill = factor(beslut_ar))) +
    geom_col() +
    labs(
      title = "Utbetalningar per år fördelat efter beslutsår",
      x = "Utbetalningsår",
      y = "Utbetalt belopp (kr)",
      fill = "Beslutsår"
    ) +
    theme_minimal()
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

