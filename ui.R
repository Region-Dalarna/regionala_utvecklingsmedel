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
               checkboxGroupInput(
                 inputId  = "valda_stodtyper",
                 label    = "Välj stödtyp:",
                 choices = c("Projektmedel"       = "PROJ",
                             "Företagsstöd"       = "FTG",
                             "Kommersiell service" = "KS"),
                 selected = c("Projektmedel", "Företagsstöd", "Kommersiell service")  # alla förkryssade från start
               ),
               h3('Beviljat belopp per år'),
               plotOutput('stapeldiagram')
      ),
      tabPanel('Projektmedel',
               h3('Beviljat belopp per år'),
               plotOutput('stapeldiagram')
      ),

      tabPanel('Företagsstöd',
               fluidRow(
                 column(3,
                        selectInput(
                          inputId  = "ftg_ar",
                          label    = "Välj år:",
                          choices  = c("Alla år", sort(unique(data_trans$beslut_ar))),
                          selected = "Alla år"
                        ),
                        radioButtons(
                          inputId  = "ftg_matt",
                          label    = "Visa som:",
                          choices  = c("Belopp" = "belopp", "Antal ärenden" = "antal"),
                          selected = "belopp"
                        )
                 ),
                 column(9,
                        h3("Fördelning kön på VD"),
                        plotOutput("ftg_kon_diagram")
                 )
               )
      ),
      tabPanel('Kommersiell service',
               h3('Beviljat belopp per år'),
               plotOutput('stapeldiagram')
      ),
      tabPanel('Om', p('Beskriv applikationen här.'))
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
  #source('global.R')
# shinyUI(
#   fluidPage(
#     tags$head(
#       tags$link(rel = 'icon', type = 'image/x-icon', href = 'favicon.ico'),
#       tags$link(rel = 'stylesheet', type = 'text/css', href = 'regiondalarna_ruf.css'),
#       tags$link(rel = 'stylesheet', type = 'text/css', href = 'app.css')
#     ))
#   ),
#
# # ---- Header (matchar .rd-header i regiondalarna_ruf.css) --------------
#     tags$div(
#       class = 'rd-header',
#       tags$div(class = 'rd-header__title', 'regionala_utvecklingsmedel'),
#       tags$a(
#         class  = 'rd-header__right',
#         href   = 'https://www.regiondalarna.se',
#         target = '_blank',
#         tags$img(src = 'logo_liggande_fri_vit.png', alt = 'Region Dalarna'),
#         tags$span('Samhällsanalys')
#       )
#     ),
#
#     # ---- Innehåll ---------------------------------------------------------
#     tabsetPanel(
#       tabPanel('Tab 1',
#         h3('Hej från regionala_utvecklingsmedel'),
#         verbatimTextOutput('På de här sidorna kan du fördjupa dig i hur de regionala utvecklingsmedlen fördelas till företag och till regionala utvecklingsprojekt')
#       ),
#       tabPanel('Om', p('Då testar jag att beskriva detta här. Beskriv applikationen här.'))
#     ),
# tabsetPanel(
#   tabPanel('Beviljat belopp',
#            h3('Beviljat belopp per år'),
#            plotOutput('stapeldiagram')
#   ),
#
#
#     # ---- Footer (matchar .rd-footer i regiondalarna_ruf.css) --------------
#     tags$div(
#       class = 'rd-footer',
#       'Samhällsanalys, Region Dalarna · ',
#       tags$a(
#         href = 'mailto:samhallsanalys@regiondalarna.se',
#         'samhallsanalys@regiondalarna.se'
#       )
#     )
#   )
# )



