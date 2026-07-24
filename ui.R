source('global.R')
shinyUI(
  fluidPage(
    tags$head(
      tags$link(rel = 'icon', type = 'image/x-icon', href = 'favicon.ico'),
      tags$link(rel = 'stylesheet', type = 'text/css', href = 'regiondalarna_ruf.css'),
      tags$link(rel = 'stylesheet', type = 'text/css', href = 'app.css')
    ),
    tags$div(
      class = 'rd-header',
      tags$div(class = 'rd-header__title', 'regionala_utvecklingsmedel'),
      tags$a(
        class  = 'rd-header__right',
        href   = 'https://www.regiondalarna.se',
        target = '_blank',
        tags$img(src = 'logo_liggande_fri_vit.png', alt = 'Region Dalarna'),
        tags$span('Samhällsanalys')
      )
    ),
    tabsetPanel(
      tabPanel('Beviljade 1:1-medel',
               fluidRow(
               column(3,
               checkboxGroupInput(
                 inputId  = "valda_ar",
                 label    = "Välj år:",
                 choices  = sort(unique(data_trans$beslut_ar)),
                 selected = sort(unique(data_trans$beslut_ar))
               ),

               checkboxGroupInput(
                 inputId  = "valda_stodtyper",
                 label    = "Välj stödtyp:",
                 choices = c("Projektmedel"        = "PROJ",
                             "Företagsstöd"        = "FTG",
                             "Kommersiell service" = "KS"),
                 selected = c("PROJ", "FTG", "KS")
                 )
               ),

               column(9,
               h3('Beviljat belopp per år'),
               plotOutput('stapeldiagram_ar_stod')
              )
          )
        ),
      tabPanel('Projektmedel',
               # Rad 1 - filter + två diagram
               fluidRow(
                 column(3,
                        checkboxGroupInput(
                          inputId  = "proj_ar",
                          label    = "Välj år:",
                          choices  = sort(unique(data_trans$beslut_ar)),
                          selected = sort(unique(data_trans$beslut_ar))
                        ),
                        radioButtons(
                          inputId  = "proj_matt",
                          label    = "Visa som:",
                          choices  = c("Beviljat belopp" = "belopp", "Antal ärenden" = "antal"),
                          selected = c("belopp")
                        )
                 ),
                 column(9,
                h3('Beviljade projektmedel per kalenderår'),
                plotOutput('proj_ar_diagram')
                )
          )
      ),

      tabPanel('Företagsstöd',
               # Rad 1 - filter + två diagram
               fluidRow(
                 column(3,
                        checkboxGroupInput(
                          inputId  = "ftg_ar",
                          label    = "Välj år:",
                          choices  = sort(unique(data_trans$beslut_ar)),
                          selected = sort(unique(data_trans$beslut_ar))
                        ),
                        radioButtons(
                          inputId  = "ftg_matt",
                          label    = "Visa som:",
                          choices  = c("Beviljat belopp" = "belopp", "Antal ärenden" = "antal", "Utbetalt belopp" = "utbet"),
                          selected = c("belopp")
                        )
                 ),
                 column(4,
                        h3("Fördelning efter VD:ns kön"),
                        plotOutput("ftg_kon_diagram")
                 ),
                 column(5,
                        h3("Fördelning per bransch"),
                        plotOutput("ftg_bransch_diagram")
                 )
               ),
               # Rad 2 - två diagram
               fluidRow(
                 column(6,
                        h3("Fördelning per kommun"),
                        plotOutput("ftg_kommun_diagram")
                 ),
                 column(6,
                        h3("Fördelning lokal klassificering 1"),
                        plotOutput("ftg_lokal_1_diagram")
                 )
               )
      ),

      tabPanel('Kommersiell service',
               fluidRow(
                 column(3,
                        checkboxGroupInput(
                          inputId  = "ks_ar",
                          label    = "Välj år:",
                          choices  = sort(unique(data_trans$beslut_ar)),
                          selected = sort(unique(data_trans$beslut_ar))
                        ),
                        radioButtons(
                          inputId  = "ks_matt",
                          label    = "Visa som:",
                          choices  = c("Beviljat belopp" = "belopp",
                                       "Antal ärenden" = "antal",
                                       "Utbetalt belopp" = "utbet"),
                          selected = c("belopp")
                        )
                 ),

                 column(9,
                      h3('Belopp per kalenderår'),
                      plotOutput('ks_kommun_diagram')
    )
    )
    ),

      tabPanel('Om',
      p('Beskriv applikationen här. Viktigt att notera:
                       Beviljade belopp registreras vid den tidpunkt då beslut fattas. Själva utbetalningen sker vid en eller flera senare tillfällen.
                       För företagsstöd görs normalt sett en utbetalning, men det förekommer att den sker kalenderåret efter ansökan beviljades.
                       För projektstöd görs utbetalningar ungefär var 4:e månad. Projektens löptid är allt ifrån 3 månader till 3 år, ibland med förlängning.
                       De beviljade totalsummorna för projektmedel under ett visst år kan förväntas betalas ut under en treårsperiod.
                       Medlen ska även motiveras med faktiska kostnader, varför det kan finnas skillnad mellan beviljat belopp och faktiskt utbetalt belopp.'))
    ),

    tags$div(
      class = 'rd-footer',
      'Samhällsanalys, Region Dalarna · ',
      tags$a(
        href = 'mailto:samhallsanalys@regiondalarna.se',
        'samhallsanalys@regiondalarna.se'
      )
    )
  )
)
