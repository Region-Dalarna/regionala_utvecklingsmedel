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
               h3('Beviljat belopp per år'),
               plotOutput('stapeldiagram')
      ),
      tabsetPanel(
        tabPanel('Projektmedel',
                 h3('Beviljat belopp per år'),
                 plotOutput('stapeldiagram')
        ),
      tabsetPanel(
        tabPanel('Företagsstöd',
                 h3('Beviljat belopp per år'),
                 plotOutput('stapeldiagram')
        ),
        tabsetPanel(
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



