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
        tabPanel('Beviljade reg. utvecklingsmedel',
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
                                   tags$div(class = 'rd-kpi-sektion-titel', textOutput('kpi_ar_text', inline = TRUE)),
                                   tags$div(class = 'rd-kpi-row',
                                            tags$div(class = 'rd-kpi',
                                                     tags$div(class = 'rd-kpi__label', 'Totalt beviljat'),
                                                     tags$div(class = 'rd-kpi__value', textOutput('kpi_totalt_beviljat', inline = TRUE))
                                            ),
                                            tags$div(class = 'rd-kpi',
                                                     tags$div(class = 'rd-kpi__label', 'Antal ärenden'),
                                                     tags$div(class = 'rd-kpi__value', textOutput('kpi_antal_arenden', inline = TRUE)),
                                                     tags$div(class = 'rd-kpi__delta', textOutput('kpi_antal_arenden_per_ar', inline = TRUE))
                                            ),
                                            tags$div(class = 'rd-kpi',
                                                     tags$div(class = 'rd-kpi__label', 'Snitt per år'),
                                                     tags$div(class = 'rd-kpi__value', textOutput('kpi_snitt_ar', inline = TRUE))
                                            )
                                   ),
                                   tags$div(class = 'rd-card',
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
                                                     girafeOutput('proj_ar_diagram', height = "380px")
                                            )
                                     ),
                                     column(6,
                                            tags$div(class = 'rd-card',
                                                     girafeOutput('proj_kohort_diagram', height = "380px")
                                            )
                                     )
                                   ),
                                   tags$div(class = 'rd-card',
                                            tags$div(style = "display:flex; justify-content:flex-end; flex-wrap:wrap; gap:10px; margin-bottom:12px;",
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
        # ============ FLIK 3: Projektbank ============

        tabPanel('Projektbank',
                 tags$div(class = 'rd-card', style = "margin-top:16px;",
                          fluidRow(
                            column(6,
                                   pickerInput(
                                     inputId  = "status_ar",
                                     label    = "Välj år:",
                                     choices  = sort(unique(year(c(data_trans$startdatum,
                                                                   data_trans$slutdatum))[
                                                                     year(c(data_trans$startdatum,
                                                                            data_trans$slutdatum)) <= year(Sys.Date())])),
                                     selected = sort(unique(year(c(data_trans$startdatum,
                                                                   data_trans$slutdatum))[
                                                                     year(c(data_trans$startdatum,
                                                                            data_trans$slutdatum)) <= year(Sys.Date())])),
                                     multiple = TRUE,
                                     options  = pickerOptions(
                                       actionsBox         = TRUE,
                                       selectedTextFormat = "count > 3",
                                       countSelectedText  = "{0} år valda"
                                     )
                                   )
                            ),

                          h2('Projektbank'),
                          p("Filtrera på projektägare, projektnamn, beviljat belopp samt tidsperiod som projektet pågått/pågår i sökrutorna nedan."),
                          DTOutput("proj_status_tabell")
                 )
        )
        ),
        # ============ FLIK 4: Företagsstöd ============
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
                                                                girafeOutput('ftg_bransch_diagram', height = "380px")
                                                      )
                                                ),
                                                column(6,
                                                       tags$div(class = 'rd-card', style = "margin-top:16px;",
                                                                girafeOutput('ftg_kon_diagram', height = "380px")
                                                       )
                                                )
                                              )
                                     ),
                                     tabPanel('Geografi',
                                              fluidRow(
                                                column(6,
                                                       tags$div(class = 'rd-card', style = "margin-top:16px;",
                                                                girafeOutput('ftg_kommun_diagram', height = "420px")
                                                       )
                                                ),
                                                column(6,
                                                       tags$div(class = 'rd-card', style = "margin-top:16px;",
                                                                girafeOutput('ftg_lokal_1_diagram', height = "420px")
                                                       )
                                                )
                                              )
                                     ),
                                     tabPanel('Utbetalningar',
                                              fluidRow(
                                                column(8,
                                                       tags$div(class = 'rd-card', style = "margin-top:16px;",
                                                                girafeOutput('ftg_kohort_diagram', height = "420px")
                                                       )
                                                ),
                                                column(4,
                                                       tags$div(class = 'rd-kpi-sektion-titel', style = "margin-top:16px;",
                                                                textOutput('ftg_kpi_ar_text', inline = TRUE)
                                                       ),
                                                       tags$div(class = 'rd-kpi',
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

        # ============ FLIK 5: Kommersiell service ============
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
                                            girafeOutput('ks_kommun_diagram', height = "460px")
                                   )
                          )
                 )
        ),

        # ============ FLIK 5: Om ============
        tabPanel('Om rapporten',
                 tags$div(class = 'rd-card', style = "margin-top:16px; max-width:900px;",
                          h2('Välkommen att utforska Region Dalarnas fördelning av regionala utvecklingsmedel'),
                          p('Dessa sidor redovisar framförallt de 1:1-medel, en summa pengar (ca 70 mnkr per år till Dalarna) som regeringen
              tilldelar regionerna, årsvis. Men även en mindre pott särskilda nationella medel (till kommersiell service). Medlen ska användas för att stimulera regional
              utveckling genom att bidra till målen i den nationella strategin för hållbar
              regional utveckling (',
                            tags$a(href = 'https://www.regeringen.se/contentassets/53af87d3b16b4f5087965691ee5fb922/nationell-strategi-for-hallbar-regional-utveckling-i-hela-landet-20212030/',
                                   target = '_blank', rel = 'noopener',
                                   'Nationell strategi för hållbar regional utveckling i hela landet 2021\u20132030'),
                            ') samt målen i den regionala utvecklingsstrategin (',
                            tags$a(href = 'https://www.regiondalarna.se/contentassets/c1cbe7a28fc640d3a5477a7b7a5f2002/dalastrategin-2030-upplaga-2026.pdf',
                                   target = '_blank', rel = 'noopener',
                                   'Dalastrategin 2030'),
                            ').'
                          ),
                          p('Medlen söks och beviljas som medfinansiering till företagsinvesteringar, att
              upprätthålla viss samhällsservice i glesbygd och till regionala
              utvecklingsprojekt.'),

                          p('Det är regionala utvecklingsnämnden som beslutar om beloppen baserat på en
              bedömning av inkomna ansökningar. Beviljade belopp registreras vid den
              tidpunkt då beslut fattas. Själva utbetalningen sker vid en eller flera
              senare tillfällen.'),
                          p('Utbetalningar ska alltid motiveras med faktiska och godkända kostnader,
              varför det kan finnas skillnad mellan beviljat belopp och faktiskt
              utbetalt belopp.'),

              p(tags$strong('Mer om stöden')),
                          p(tags$strong('Företagsstöd'), ' \u2013 syftet med företagsstöden är att bidra till en hållbar regional utveckling och tillväxt i små och medelstora företag verksamma i Dalarna.
                          Stöden ska underlätta för små- och medelstora företag (SMF) som är verksamma i Dalarna och som har en nationell/ internationell marknad att genomföra investeringar.
Utbetalning av företagsstöd sker inom varierande tidsramar beroende på investeringens omfattning, stödets storlek samt företagets egna förutsättningar att genomföra investeringen. Stödet kan betalas ut vid ett eller flera tillfällen.  Det kan därför förekomma att ett beviljat stöd helt eller delvis utbetalas under nästkommande kalenderår.'),
                          p(tags$strong('Projektstöd'), ' \u2013 regionala utvecklingsprojekt bedrivs av exempelvis kommuner,
företagsfrämjarorganisationer och länsstyrelsen, men även av Region Dalarna. Utvecklingsprojekt finansieras ofta
med ca hälften 1:1-medel och hälften EU-medel, framförallt från ERUF
(Europeiska regionalfonden, ',
                            tags$a(href = 'https://tillvaxtverket.se/tillvaxtverket/omtillvaxtverket/eufonder/regionalfonden/norramellansverige.3581.html',
                                   target = '_blank', rel = 'noopener',
                                   'Norra Mellansverige - Tillväxtverket'),
                          ').'
                          ),
              p('Projektens löptid är allt ifrån 3 månader till 3 år, ibland med förlängning. Utbetalningar för projektstöd görs
              vanligtvis ungefär var 4:e månad. De beviljade totalsummorna för
              projektmedel under ett visst år förväntas därför fördelas över en längre
              tid samtidigt som beslut från tidigare år ligger som fasta betalningsåtaganden.'),

              p(tags$strong('Stöd till kommersiell service'), ' \u2013 stöd till kommersiell service bidrar till att bibehålla och utveckla den lokala servicen på landsbygder.
  Stödet består av fyra delar och finansieras både från 1:1-medlen och från särskilda nationella medel som Tillväxtverket förvaltar.
  Merparten av stödet går till dagligvarubutiker och drivmedelsanläggningar för drift (särskilt driftstöd) och investeringar (investeringsstöd), och vid särskilda situationer för att överbrygga lönsamhetsproblem (servicebidrag).
  En liten andel ges även till kommuner som ersättning för hemsändning av dagligvaror (hemsändningsbidrag) till enskilda hushåll.'
              ),
              p('Läs mer om ',
                tags$a(href = 'https://www.regiondalarna.se/verksamhet/regional-utveckling/projektmedel-stod-och-bidrag/stod-till-kommersiell-service/',
                       target = '_blank', rel = 'noopener',
                       'stöd till kommersiell service'),
                ' på Region Dalarnas webbplats.'
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
)


