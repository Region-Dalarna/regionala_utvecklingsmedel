source('global.R')
shinyUI(
  fluidPage(
    useShinyjs(),
    tags$head(
      tags$link(rel = 'icon', type = 'image/x-icon', href = 'favicon.ico'),
      tags$link(rel = 'stylesheet', type = 'text/css', href = 'regiondalarna_ruf.css'),
      tags$link(rel = 'stylesheet', type = 'text/css', href = 'app.css')
    ),
    tags$div(
      class = 'rd-header',
      tags$div(class = 'rd-header__title', 'Regionala utvecklingsmedel'),
      tags$a(
        class  = 'rd-header__right',
        href   = 'https://www.regiondalarna.se',
        target = '_blank',
        tags$img(src = 'logo_liggande_fri_vit.png', alt = 'Region Dalarna'),
        tags$span('Samhällsanalys')
      )
    ),

    tags$div(
      style = "max-width:1400px; margin:0 auto; padding: 0 24px;",

      tabsetPanel(
        id = "huvudflikar",

        # ============ FLIK 1: Beviljade 1:1-medel ============
        tabPanel('Beviljade 1:1-medel',
                 tags$div(class = 'rd-app',
                          tags$div(class = 'rd-sidebar',
                                   h3('Filter'),
                                   tags$div(class = 'rd-field',
                                            pickerInput(
                                              inputId  = "valda_ar",
                                              label    = "Välj år:",
                                              choices  = sort(unique(data_trans$beslut_ar)),
                                              selected = sort(unique(data_trans$beslut_ar)),
                                              multiple = TRUE,
                                              options  = pickerOptions(actionsBox = TRUE, selectedTextFormat = "count > 3", countSelectedText = "{0} år valda")
                                            )
                                   ),
                                   tags$div(class = 'rd-field',
                                            checkboxGroupInput(
                                              inputId  = "valda_stodtyper",
                                              label    = "Välj stödtyp:",
                                              choices  = c("Projektmedel"        = "PROJ",
                                                           "Företagsstöd"        = "FTG",
                                                           "Kommersiell service" = "KS"),
                                              selected = c("PROJ", "FTG", "KS")
                                            )
                                   )
                          ),
                          tags$div(class = 'rd-main',
                                   tags$div(class = 'rd-kpi-row',
                                            tags$div(class = 'rd-kpi',
                                                     tags$div(class = 'rd-kpi__label', 'Totalt beviljat'),
                                                     tags$div(class = 'rd-kpi__value', textOutput('kpi_totalt_beviljat', inline = TRUE))
                                            ),
                                            tags$div(class = 'rd-kpi',
                                                     tags$div(class = 'rd-kpi__label', 'Antal ärenden'),
                                                     tags$div(class = 'rd-kpi__value', textOutput('kpi_antal_arenden', inline = TRUE))
                                            ),
                                            tags$div(class = 'rd-kpi',
                                                     tags$div(class = 'rd-kpi__label', 'Snitt per år'),
                                                     tags$div(class = 'rd-kpi__value', textOutput('kpi_snitt_ar', inline = TRUE))
                                            )
                                   ),
                                   tags$div(class = 'rd-card',
                                            h2('Beviljat belopp per år'),
                                            girafeOutput('stapeldiagram_ar_stod', height = "420px")
                                   )
                          )
                 )
        ),

        # ============ FLIK 2: Projektmedel ============
        tabPanel('Projektmedel',
                 tags$div(class = 'rd-app',
                          tags$div(class = 'rd-sidebar',
                                   h3('Filter'),
                                   tags$div(class = 'rd-field',
                                            pickerInput(
                                              inputId  = "proj_ar",
                                              label    = "Välj år:",
                                              choices  = sort(unique(data_trans$beslut_ar)),
                                              selected = sort(unique(data_trans$beslut_ar)),
                                              multiple = TRUE,
                                              options  = pickerOptions(actionsBox = TRUE, selectedTextFormat = "count > 3", countSelectedText = "{0} år valda")
                                            )
                                   ),
                                   tags$div(class = 'rd-field',
                                            tags$label(class = 'rd-label', 'Visa som:'),
                                            tags$div(class = 'rd-segmented',
                                                     radioGroupButtons(
                                                       inputId  = "proj_matt",
                                                       label    = NULL,
                                                       choices  = c("Beviljat belopp" = "belopp", "Antal ärenden" = "antal"),
                                                       selected = "belopp"
                                                     )
                                            )
                                   )
                          ),
                          tags$div(class = 'rd-main',
                                   fluidRow(
                                     column(6,
                                            tags$div(class = 'rd-card',
                                                     h2('Beviljade projektmedel per kalenderår'),
                                                     girafeOutput('proj_ar_diagram', height = "380px")
                                            )
                                     ),
                                     column(6,
                                            tags$div(class = 'rd-card',
                                                     h2('Utbetalningar per beslutskohort'),
                                                     girafeOutput('proj_kohort_diagram', height = "380px")
                                            )
                                     )
                                   ),
                                   tags$div(class = 'rd-card',
                                            tags$div(style = "display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px; margin-bottom:12px;",
                                                     h2('Fördelning', style = "margin:0;"),
                                                     tags$div(class = 'rd-segmented',
                                                              radioGroupButtons(
                                                                inputId  = "proj_fordelning_typ",
                                                                label    = NULL,
                                                                choices  = c("Strategiområde" = "strat", "Resultatkedja" = "kedja"),
                                                                selected = "strat"
                                                              )
                                                     )
                                            ),
                                            girafeOutput('proj_fordelning_diagram', height = "420px")
                                   )
                          )
                 )
        ),

        # ============ FLIK 3: Företagsstöd ============
        tabPanel('Företagsstöd',
                 tags$div(class = 'rd-app',
                          tags$div(class = 'rd-sidebar',
                                   h3('Filter'),
                                   tags$div(class = 'rd-field',
                                            pickerInput(
                                              inputId  = "ftg_ar",
                                              label    = "Välj år:",
                                              choices  = sort(unique(data_trans$beslut_ar)),
                                              selected = sort(unique(data_trans$beslut_ar)),
                                              multiple = TRUE,
                                              options  = pickerOptions(actionsBox = TRUE, selectedTextFormat = "count > 3", countSelectedText = "{0} år valda")
                                            )
                                   ),
                                   tags$div(class = 'rd-field',
                                            tags$label(class = 'rd-label', 'Visa som:'),
                                            tags$div(class = 'rd-segmented',
                                                     radioGroupButtons(
                                                       inputId  = "ftg_matt",
                                                       label    = NULL,
                                                       choices  = c("Beviljat belopp" = "belopp", "Antal ärenden" = "antal", "Utbetalt belopp" = "utbet"),
                                                       selected = "belopp"
                                                     )
                                            )
                                   )
                          ),
                          tags$div(class = 'rd-main',
                                   tabsetPanel(
                                     tabPanel('Översikt',
                                              fluidRow(
                                                column(6,
                                                       tags$div(class = 'rd-card', style = "margin-top:16px;",
                                                                h2("Fördelning efter VD:ns kön"),
                                                                girafeOutput('ftg_kon_diagram', height = "380px")
                                                       )
                                                ),
                                                column(6,
                                                       tags$div(class = 'rd-card', style = "margin-top:16px;",
                                                                h2("Fördelning per bransch"),
                                                                girafeOutput('ftg_bransch_diagram', height = "380px")
                                                       )
                                                )
                                              )
                                     ),
                                     tabPanel('Geografi',
                                              fluidRow(
                                                column(6,
                                                       tags$div(class = 'rd-card', style = "margin-top:16px;",
                                                                h2("Fördelning per kommun"),
                                                                girafeOutput('ftg_kommun_diagram', height = "420px")
                                                       )
                                                ),
                                                column(6,
                                                       tags$div(class = 'rd-card', style = "margin-top:16px;",
                                                                h2("Fördelning klassificering 1"),
                                                                girafeOutput('ftg_lokal_1_diagram', height = "420px")
                                                       )
                                                )
                                              )
                                     ),
                                     tabPanel('Utbetalningar',
                                              fluidRow(
                                                column(8,
                                                       tags$div(class = 'rd-card', style = "margin-top:16px;",
                                                                h2("Beslutsår i relation till utbetalningsår"),
                                                                girafeOutput('ftg_kohort_diagram', height = "420px")
                                                       )
                                                ),
                                                column(4,
                                                       tags$div(class = 'rd-kpi', style = "margin-top:16px;",
                                                                tags$div(class = 'rd-kpi__label', 'Totalt utbetalt'),
                                                                tags$div(class = 'rd-kpi__value', textOutput('ftg_kpi_utbetalt', inline = TRUE))
                                                       ),
                                                       tags$div(class = 'rd-kpi', style = "margin-top:16px;",
                                                                tags$div(class = 'rd-kpi__label', 'Andel av beviljat'),
                                                                tags$div(class = 'rd-kpi__value', textOutput('ftg_kpi_andel', inline = TRUE))
                                                       )
                                                )
                                              )
                                     )
                                   )
                          )
                 )
        ),

        # ============ FLIK 4: Kommersiell service ============
        tabPanel('Kommersiell service',
                 tags$div(class = 'rd-app',
                          tags$div(class = 'rd-sidebar',
                                   h3('Filter'),
                                   tags$div(class = 'rd-field',
                                            pickerInput(
                                              inputId  = "ks_ar",
                                              label    = "Välj år:",
                                              choices  = sort(unique(data_trans$beslut_ar)),
                                              selected = sort(unique(data_trans$beslut_ar)),
                                              multiple = TRUE,
                                              options  = pickerOptions(actionsBox = TRUE, selectedTextFormat = "count > 3", countSelectedText = "{0} år valda")
                                            )
                                   ),
                                   tags$div(class = 'rd-field',
                                            tags$label(class = 'rd-label', 'Visa som:'),
                                            tags$div(class = 'rd-segmented',
                                                     radioGroupButtons(
                                                       inputId  = "ks_matt",
                                                       label    = NULL,
                                                       choices  = c("Beviljat belopp" = "belopp", "Antal ärenden" = "antal", "Utbetalt belopp" = "utbet"),
                                                       selected = "belopp"
                                                     )
                                            )
                                   )
                          ),
                          tags$div(class = 'rd-main',
                                   tags$div(class = 'rd-card',
                                            h2('Belopp per kommun'),
                                            girafeOutput('ks_kommun_diagram', height = "460px")
                                   )
                          )
                 )
        ),

        # ============ FLIK 5: Om ============
        tabPanel('Om',
                 tags$div(class = 'rd-card', style = "margin-top:16px; max-width:900px;",
                          p('Beskriv applikationen här. Viktigt att notera:
              Beviljade belopp registreras vid den tidpunkt då beslut fattas. Själva utbetalningen sker vid en eller flera senare tillfällen.
              För företagsstöd görs normalt sett en utbetalning, men det förekommer att den sker kalenderåret efter ansökan beviljades.
              För projektstöd görs utbetalningar ungefär var 4:e månad. Projektens löptid är allt ifrån 3 månader till 3 år, ibland med förlängning.
              De beviljade totalsummorna för projektmedel under ett visst år förväntas således betalas ut under en treårsperiod.
              Utbetalningar ska även motiveras med faktiska och godkända kostnader, varför det kan finnas skillnad mellan beviljat belopp och faktiskt utbetalt belopp.'
                          )
                 )
        )
      )
    ),

    tags$div(
      class = 'rd-footer',
      'Samhällsanalys, Region Dalarna \u00b7 ',
      tags$a(
        href = 'mailto:samhallsanalys@regiondalarna.se',
        'samhallsanalys@regiondalarna.se'
      )
    )
  )
)
