shinyServer(function(input, output, session) {

  # ============================================================
  # FLIK 1: Beviljade 1:1-medel
  # ============================================================

  bas1_data <- reactive({
    req(input$valda_stodtyper, input$valda_ar)
    data_trans |>
      filter(stodtyp %in% input$valda_stodtyper,
             beslut_ar %in% input$valda_ar)
  })

  output$kpi_ar_text <- renderText({
    paste0("Nyckeltal f\u00f6r \u00e5r ", formatera_ar_intervall(input$valda_ar))
  })

  output$kpi_totalt_beviljat <- renderText({
    varde <- bas1_data() |>
      summarise(v = sum(beviljat_belopp, na.rm = TRUE)) |>
      pull(v)
    scales::label_number(big.mark = " ", suffix = " kr")(varde)
  })

  output$kpi_antal_arenden <- renderText({
    varde <- bas1_data() |>
      summarise(v = n_distinct(arende)) |>
      pull(v)
    scales::label_number(big.mark = " ")(varde)
  })

  output$kpi_antal_arenden_per_ar <- renderText({
    df       <- bas1_data()
    antal_ar <- n_distinct(df$beslut_ar)
    antal    <- n_distinct(df$arende)
    snitt    <- if (antal_ar > 0) antal / antal_ar else 0
    paste0("\u2248 ", scales::label_number(big.mark = " ", accuracy = 1)(snitt), " / \u00e5r")
  })

  output$kpi_snitt_ar <- renderText({
    df        <- bas1_data()
    antal_ar  <- n_distinct(df$beslut_ar)
    totalt    <- sum(df$beviljat_belopp, na.rm = TRUE)
    snitt     <- if (antal_ar > 0) totalt / antal_ar else 0
    scales::label_number(big.mark = " ", suffix = " kr")(snitt)
  })

  output$stapeldiagram_ar_stod <- renderGirafe({
    plot_data <- bas1_data() |>
      group_by(beslut_ar, stodtyp) |>
      summarise(summa = sum(beviljat_belopp, na.rm = TRUE), .groups = "drop") |>
      # Fyll på med 0 för år/stödtyp-kombinationer som saknar data, så att
      # position = "dodge" alltid delar upp bredden mellan samma antal
      # grupper - annars blir staplarna bredare de år en stödtyp saknas.
      complete(beslut_ar, stodtyp, fill = list(summa = 0)) |>
      mutate(
        stodtyp_etikett = etiketter_stodtyp[stodtyp],
        tooltip_text    = paste0("Stödtyp: ", stodtyp_etikett, "<br>",
                                 "\u00c5r: ", beslut_ar, "<br>",
                                 "Summa: ", scales::comma(summa, big.mark = " "), " kr")
      )

    p <- ggplot(plot_data, aes(x = factor(beslut_ar), y = summa, fill = stodtyp,
                               tooltip = tooltip_text,
                               data_id = interaction(beslut_ar, stodtyp))) +
      geom_col_interactive(position = "dodge") +
      scale_fill_manual(values = farger_stodtyp, labels = etiketter_stodtyp) +
      labs(title = "Beviljat belopp per år", x = "År",
           y = "Summa beviljat belopp (kr)", fill = "Stödtyp",
           caption = KALLA_TEXT) +
      tema_rd_diagram() +
      skala_y_tal()

    girafe(ggobj = p, options = opts_girafe_std(), width_svg = 11, height_svg = 4.8)
  })

  # ============================================================
  # FLIK 2: Projektmedel
  # ============================================================

  proj_data <- reactive({
    req(input$proj_ar)
    data_trans |>
      filter(stodtyp == "PROJ", beslut_ar %in% input$proj_ar)
  })

  output$proj_ar_diagram <- renderGirafe({
    plot_data <- proj_data() |>
      group_by(beslut_ar) |>
      berakna_varde(input$proj_matt) |>
      mutate(tooltip_text = paste0("\u00c5r: ", beslut_ar, "<br>",
                                   matt_etiketter[[input$proj_matt]], ": ",
                                   format_varde_matt(varde, input$proj_matt)))

    p <- ggplot(plot_data, aes(x = factor(beslut_ar), y = varde,
                               tooltip = tooltip_text, data_id = factor(beslut_ar))) +
      geom_col_interactive(fill = farg_standard) +
      labs(title = "Projektmedel per kalenderår", x = "År",
           y = y_lab_matt(input$proj_matt), caption = KALLA_TEXT) +
      tema_rd_diagram() +
      skala_y_tal() +
      theme(legend.position = "none")

    girafe(ggobj = p, options = opts_girafe_std())
  })

  output$proj_kohort_diagram <- renderGirafe({
    req(input$proj_ar)

    plot_data <- data_trans |>
      filter(stodtyp == "PROJ",
             beslut_ar %in% input$proj_ar,
             trans_ar <= year(Sys.Date())) |>
      group_by(beslut_ar, trans_ar) |>
      summarise(utbet = sum(utbet_belopp, na.rm = TRUE), .groups = "drop")

    farger_ar <- skapa_farger_ar(plot_data$beslut_ar)

    plot_data <- plot_data |>
      mutate(tooltip_text = paste0("Utbetalningsår: ", trans_ar, "<br>",
                                   "Beslutsår: ", beslut_ar, "<br>",
                                   "Summa: ", scales::comma(utbet, big.mark = " "), " kr"))

    p <- ggplot(plot_data, aes(x = factor(trans_ar), y = utbet, fill = factor(beslut_ar),
                               tooltip = tooltip_text,
                               data_id = interaction(trans_ar, beslut_ar))) +
      geom_col_interactive() +
      scale_fill_manual(values = farger_ar) +
      labs(title = "Utbetalningar per år fördelat efter beslutsår",
           x = "Utbetalningsår", y = "Utbetalt belopp (kr)", fill = "Beslutsår",
           caption = KALLA_TEXT) +
      tema_rd_diagram() +
      skala_y_tal()

    girafe(ggobj = p, options = opts_girafe_std())
  })

  # Fördelning strategiområde / resultatkedja - ett diagram, växlas med knapp
  output$proj_fordelning_diagram <- renderGirafe({
    req(input$proj_ar, input$proj_fordelning_typ)

    grupp_var <- if (input$proj_fordelning_typ == "strat") "nat_strat_ren" else "resultatkedja_ren"
    titel     <- if (input$proj_fordelning_typ == "strat") "Fördelning per nationellt strategiområde" else "Fördelning per resultatkedja"
    x_lab     <- if (input$proj_fordelning_typ == "strat") "Strategiområde" else "Resultatkedja"

    plot_data <- proj_data() |>
      # 2018 saknar data för strategiområde/resultatkedja
      filter(beslut_ar != 2018, !is.na(.data[[grupp_var]])) |>
      group_by(.data[[grupp_var]], beslut_ar) |>
      berakna_varde(input$proj_matt) |>
      ungroup() |>
      mutate(
        kategori_full = as.character(.data[[grupp_var]]),
        kategori_kort = str_trunc(kategori_full, width = 24, ellipsis = "\u2026"),
        # Fullständigt (ej avkortat) kategorinamn i hover, plus beslutsår och summa på egna rader
        tooltip_text  = paste0(x_lab, ": ", kategori_full, "<br>",
                               "Beslutsår: ", beslut_ar, "<br>",
                               matt_etiketter[[input$proj_matt]], ": ",
                               format_varde_matt(varde, input$proj_matt))
      )

    farger_ar <- skapa_farger_ar(plot_data$beslut_ar)

    p <- ggplot(plot_data, aes(x = kategori_kort, y = varde, fill = factor(beslut_ar),
                               tooltip = tooltip_text,
                               data_id = interaction(kategori_full, beslut_ar))) +
      geom_col_interactive(position = "stack") +
      scale_fill_manual(values = farger_ar) +
      labs(title = titel,
           x = x_lab, y = y_lab_matt(input$proj_matt), fill = "Beslutsår",
           caption = KALLA_TEXT) +
      tema_rd_diagram() +
      skala_y_tal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))

    girafe(ggobj = p, options = opts_girafe_std(), width_svg = 11, height_svg = 4.8)
  })

  # ============================================================
  # FLIK 3: Företagsstöd
  # ============================================================

  ftg_data <- reactive({
    req(input$ftg_ar)
    data_trans |>
      filter(stodtyp == "FTG", beslut_ar %in% input$ftg_ar)
  })

  # -- Inre flik: Översikt --

  output$ftg_kon_diagram <- renderGirafe({
    plot_data <- ftg_data() |>
      filter(!is.na(vd_kon_ren)) |>
      group_by(vd_kon_ren) |>
      berakna_varde(input$ftg_matt) |>
      mutate(tooltip_text = paste0("Kön: ", vd_kon_ren, "<br>",
                                   matt_etiketter[[input$ftg_matt]], ": ",
                                   format_varde_matt(varde, input$ftg_matt)))

    # X-axeln visar kön, inte år - lägg därför till valda år i rubriken.
    ar_text <- formatera_ar_intervall(ftg_data()$beslut_ar)

    p <- ggplot(plot_data, aes(x = vd_kon_ren, y = varde, fill = vd_kon_ren,
                               tooltip = tooltip_text, data_id = vd_kon_ren)) +
      geom_col_interactive() +
      scale_fill_manual(values = farger_kon) +
      labs(title = paste0("Könsfördelning på VD-posten år ", ar_text),
           x = "Kön", y = y_lab_matt(input$ftg_matt), caption = KALLA_TEXT) +
      tema_rd_diagram() +
      skala_y_tal() +
      theme(legend.position = "none")

    girafe(ggobj = p, options = opts_girafe_std())
  })

  output$ftg_bransch_diagram <- renderGirafe({
    p <- bygg_kategori_diagram(ftg_data(), "bransch_avd_2025", input$ftg_matt,
                               "Fördelning per bransch", "Bransch",
                               rensa_fn = rensa_branschnamn)
    girafe(ggobj = p, options = opts_girafe_std())
  })

  # -- Inre flik: Geografi --

  output$ftg_kommun_diagram <- renderGirafe({
    p <- bygg_kategori_diagram(ftg_data(), "arbetsstalle", input$ftg_matt,
                               "Fördelning per kommun", "Kommun")
    girafe(ggobj = p, options = opts_girafe_std())
  })

  output$ftg_lokal_1_diagram <- renderGirafe({
    p <- bygg_kategori_diagram(ftg_data(), "lokal_1", input$ftg_matt,
                               "Fördelning klassificering 1", "Klassificering")
    girafe(ggobj = p, options = opts_girafe_std())
  })

  # -- Inre flik: Utbetalningar --

  output$ftg_kohort_diagram <- renderGirafe({
    req(input$ftg_ar)

    plot_data <- data_trans |>
      filter(stodtyp == "FTG",
             beslut_ar %in% input$ftg_ar,
             trans_ar <= year(Sys.Date())) |>
      group_by(beslut_ar, trans_ar) |>
      summarise(utbet = sum(utbet_belopp, na.rm = TRUE), .groups = "drop")

    farger_ar <- skapa_farger_ar(plot_data$beslut_ar)

    plot_data <- plot_data |>
      mutate(tooltip_text = paste0("Utbetalningsår: ", trans_ar, "<br>",
                                   "Beslutsår: ", beslut_ar, "<br>",
                                   "Summa: ", scales::comma(utbet, big.mark = " "), " kr"))

    p <- ggplot(plot_data, aes(x = factor(trans_ar), y = utbet, fill = factor(beslut_ar),
                               tooltip = tooltip_text,
                               data_id = interaction(trans_ar, beslut_ar))) +
      geom_col_interactive() +
      scale_fill_manual(values = farger_ar) +
      labs(title = "Utbetalningar per år fördelat efter beslutsår",
           x = "Utbetalningsår", y = "Utbetalt belopp (kr)", fill = "Beslutsår",
           caption = KALLA_TEXT) +
      tema_rd_diagram() +
      skala_y_tal()

    girafe(ggobj = p, options = opts_girafe_std(), width_svg = 8, height_svg = 5.2)
  })

  output$ftg_kpi_ar_text <- renderText({
    paste0("Nyckeltal f\u00f6r \u00e5r ", formatera_ar_intervall(input$ftg_ar))
  })

  output$ftg_kpi_utbetalt <- renderText({
    varde <- ftg_data() |>
      summarise(v = sum(utbet_belopp, na.rm = TRUE)) |>
      pull(v)
    scales::label_number(big.mark = " ", suffix = " kr")(varde)
  })

  output$ftg_kpi_andel <- renderText({
    df        <- ftg_data()
    beviljat  <- sum(df$beviljat_belopp, na.rm = TRUE)
    utbetalt  <- sum(df$utbet_belopp, na.rm = TRUE)
    andel     <- if (beviljat > 0) utbetalt / beviljat else 0
    scales::label_percent(accuracy = 1)(andel)
  })

  # ============================================================
  # FLIK 4: Kommersiell service
  # ============================================================

  ks_data <- reactive({
    req(input$ks_ar)
    data_trans |>
      filter(stodtyp == "KS", beslut_ar %in% input$ks_ar)
  })

  output$ks_kommun_diagram <- renderGirafe({
    p <- bygg_kategori_diagram(ks_data(), "arbetsstalle", input$ks_matt,
                               "Belopp per kommun", "Kommun")
    girafe(ggobj = p, options = opts_girafe_std(), width_svg = 10.5, height_svg = 5.4)
  })

})
