## Globala inställningar för Shinyappen: regionala_utvecklingsmedel

# Ladda nödvändiga paket
library(shiny)
library(shinyjs)
library(shinyWidgets)
library(DT)
library(ggiraph)
library(dplyr)
library(tidyr)
library(purrr)
library(stringr)
library(readr)
library(ggplot2)
library(lubridate)
library(scales)
library(dbplyr)

# Delade RD-funktioner, bl.a. databaskoppling shiny_uppkoppling_las()
source("https://raw.githubusercontent.com/Region-Dalarna/funktioner/main/func_shinyappar.R", encoding = "utf-8", echo = FALSE)

# Allmänna options - TRUE = visa inte R-felmeddelanden i appen, FALSE = visa felmeddelanden från R på webben
options(shiny.sanitize.errors = FALSE)

# Stäng av vetenskaplig notation globalt (påverkar bl.a. axeletiketter i
# ggplot2/scales). Sätts här istället för scientific=FALSE i label_number(),
# eftersom det argumentet krockar internt i nyare versioner av scales-paketet
# ("formal argument 'scientific' matched by multiple actual arguments").
options(scipen = 999)

# ============================================================
# DATAINLÄSNING
# Databasen oppna_data, schema nyps, tabeller trans/adresser/finans
# i första hand. Om kopplingen mot databasen inte är konfigurerad
# (t.ex. på en lokal dator utan uppsatta credentials) faller
# skriptet tillbaka på lokala RDS-filer i en mapp på G:.
#
# OBS: kolumnnamnen nedan förutsätter att oppna_data.nyps.trans/
# .adresser/.finans har samma kolumnnamn som dagens RDS-filer
# (beslut_ar, stodtyp, beviljat_belopp, utbet_belopp, arende,
# trans_ar, nat_strat_ren, resultatkedja_ren, vd_kon_ren,
# bransch_avd_2025, arbetsstalle, lokal_1 m.fl.). Justera
# hamta_data() vid behov när tabellerna finns på plats i skarp drift.
# ============================================================

data_sokvag_lokal <- "g:/skript/shiny_data/regionala_utvecklingsmedel/"

hamta_data <- function() {
  tryCatch({
    con <- shiny_uppkoppling_las("oppna_data")
    list(
      data_trans    = dplyr::tbl(con, dbplyr::in_schema("nyps", "trans"))    |> dplyr::collect(),
      data_adresser = dplyr::tbl(con, dbplyr::in_schema("nyps", "adresser")) |> dplyr::collect(),
      data_finans   = dplyr::tbl(con, dbplyr::in_schema("nyps", "finans"))   |> dplyr::collect()
    )
  }, error = function(e) {
    if (dir.exists(data_sokvag_lokal)) {
      message("Kunde inte koppla mot databasen (", conditionMessage(e),
              "). Läser lokala RDS-filer istället: ", data_sokvag_lokal)
      list(
        data_trans    = readRDS(file.path(data_sokvag_lokal, "data_trans_clean.rds")),
        data_adresser = readRDS(file.path(data_sokvag_lokal, "data_adresser_clean.rds")),
        data_finans   = readRDS(file.path(data_sokvag_lokal, "data_finans_clean.rds"))
      )
    } else {
      stop("Kunde varken koppla mot databasen eller hitta lokal datamapp: ",
           data_sokvag_lokal, call. = FALSE)
    }
  })
}

data_lista    <- hamta_data()
data_trans    <- data_lista$data_trans
data_adresser <- data_lista$data_adresser
data_finans   <- data_lista$data_finans

# ============================================================
# FÄRGDEFINITIONER (Region Dalarnas identitet, matchar
# regiondalarna_ruf.css / app.css)
# ============================================================

# Stödtyp
farger_stodtyp <- c(
  "PROJ" = "#158daf",  # --rd-primary
  "FTG"  = "#00b4e4",  # --rd-blue-bright
  "KS"   = "#54a1bd"   # --rd-accent
)
etiketter_stodtyp <- c(
  "PROJ" = "Projektmedel",
  "FTG"  = "Företagsstöd",
  "KS"   = "Kommersiell service"
)

# Kön (VD)
farger_kon <- c(
  "Kvinna" = "#e2a855",  # --rd-kon-kvinnor
  "Man"    = "#459079"   # --rd-kon-man
)

# Enfärgad standard för diagram utan gruppering (kategori-diagram)
farg_standard <- "#158daf"  # --rd-primary

# Sekventiell blåpalett för år (kohortdiagram) - alla år behöver inte
# egen unik kulör, en gradient räcker för att skilja tidiga/sena år åt.
skapa_farger_ar <- function(ar_vektor) {
  ar_sorterade <- sort(unique(ar_vektor))
  pal <- colorRampPalette(c("#b6f0fd", "#0074a2"))  # --rd-blue-pale -> --rd-blue-deep
  set_names(pal(length(ar_sorterade)), ar_sorterade)
}

# ============================================================
# MÅTTLOGIK (belopp / antal / utbetalt) - ersätter upprepade
# if/else-kedjor i server.R
# ============================================================

matt_etiketter <- c(
  "belopp" = "Beviljat belopp",
  "antal"  = "Antal ärenden",
  "utbet"  = "Utbetalt belopp"
)

berakna_varde <- function(data_grupperad, matt) {
  switch(matt,
         "belopp" = data_grupperad |> summarise(varde = sum(beviljat_belopp, na.rm = TRUE), .groups = "drop"),
         "antal"  = data_grupperad |> summarise(varde = n_distinct(arende), .groups = "drop"),
         "utbet"  = data_grupperad |> summarise(varde = sum(utbet_belopp, na.rm = TRUE), .groups = "drop")
  )
}

# Y-axeletikett för valt mått - lägger på "(kr)" för kronbelopp, inte för antal
y_lab_matt <- function(matt) {
  if (matt == "antal") matt_etiketter[[matt]] else paste0(matt_etiketter[[matt]], " (kr)")
}

# Formaterar ett värde med tusentalsavgränsare och lägger på "kr" där det är relevant
format_varde_matt <- function(varde, matt) {
  if (matt == "antal") {
    scales::comma(varde, big.mark = " ")
  } else {
    paste0(scales::comma(varde, big.mark = " "), " kr")
  }
}

# Formaterar en årsvektor till "2018\u20132026" om åren är sammanhängande,
# annars en kommaseparerad lista - används i hover/rubriker för att visa
# vilka år som ingår. as.numeric() hanterar att pickerInput/checkboxGroupInput
# alltid returnerar valda värden som character (t.ex. "2018").
formatera_ar_intervall <- function(ar_vektor) {
  ar <- sort(unique(as.numeric(ar_vektor)))
  if (length(ar) == 0) {
    ""
  } else if (length(ar) > 1 && all(diff(ar) == 1)) {
    paste0(min(ar), "\u2013", max(ar))
  } else {
    paste(ar, collapse = ", ")
  }
}

# ============================================================
# DELAD DIAGRAMLOGIK
# ============================================================

# Källhänvisning som ska visas som caption i alla diagram
KALLA_TEXT <- "K\u00e4lla: Nyps (Tillv\u00e4xtverket), bearbetningar av Samh\u00e4llsanalys, Region Dalarna"

# Standardtema för alla diagram i appen
tema_rd_diagram <- function() {
  theme_minimal(base_size = 12) +
    theme(
      plot.title       = element_text(face = "bold", size = 13, color = "#212529"),
      plot.caption     = element_text(size = 8, color = "#6c757d", hjust = 0,
                                      margin = margin(t = 10)),
      axis.title       = element_text(size = 10, color = "#6c757d"),
      axis.text        = element_text(size = 9, color = "#212529"),
      legend.title     = element_text(size = 9),
      legend.text      = element_text(size = 9),
      panel.grid.minor = element_blank()
    )
}

# Axelskala utan vetenskaplig notation, med mellanslag som tusentalsavgränsare.
# scientific = FALSE skickas medvetet INTE med här, se options(scipen = 999) ovan.
skala_y_tal <- function() {
  scale_y_continuous(labels = scales::label_number(big.mark = " ", decimal.mark = ","))
}

# Standardinställningar för hover/tooltip/verktygsfält i alla girafe-diagram
opts_girafe_std <- function() {
  list(
    opts_hover(css = "fill:#0f7090;stroke:#0f7090;cursor:pointer;"),
    opts_hover_inv(css = "opacity:0.35;"),
    opts_tooltip(
      css = "background:#ffffff;color:#212529;border:1px solid #e3e8ed;
             border-radius:6px;padding:8px 10px;
             font-family:'Poppins',Arial,Helvetica,sans-serif;
             font-size:0.85rem;box-shadow:0 1px 2px rgba(0,0,0,0.08);"
    ),
    # Endast nedladdning (saveaspng) + fullskärm synliga - lasso-markering
    # (select/deselect) är dold eftersom den inte används i appen.
    opts_toolbar(saveaspng = TRUE, hidden = c("lasso_select", "lasso_deselect")),
    # Låt diagrammet skala till 100 % av kortets bredd istället för en
    # fast bredd på 6 tum med vit yta runt om.
    opts_sizing(rescale = TRUE, width = 1)
  )
}

# Tar bort SNI-avdelningens bokstav framför branschnamn (t.ex. "C Tillverkning"
# -> "Tillverkning") och normaliserar helt versala värden (t.ex. "UPPGIFT
# SAKNAS" -> "Uppgift saknas") till vanlig meningsform.
rensa_branschnamn <- function(x) {
  x |>
    str_remove("^[A-ZÅÄÖ]\\s+") |>
    str_to_sentence()
}

# Generisk fördelning: en kategorikolumn, ett mått, horisontella staplar
# sorterade efter värde. Används för bransch/kommun/klassificering m.fl.
# rensa_fn kan skickas in för att städa kategorinamnen innan de visas
# (t.ex. rensa_branschnamn för bransch_avd_2025).
bygg_kategori_diagram <- function(data, grupp_var, matt, titel, x_lab, farg = farg_standard, rensa_fn = identity) {
  # Vilka år ingår i underlaget - samma för alla staplar eftersom filtret
  # (valda år) gäller hela datasetet innan gruppering per kategori.
  ar_text <- formatera_ar_intervall(data$beslut_ar)

  plot_data <- data |>
    filter(!is.na(.data[[grupp_var]])) |>
    group_by(.data[[grupp_var]]) |>
    berakna_varde(matt) |>
    ungroup() |>
    mutate(
      kategori_full = rensa_fn(as.character(.data[[grupp_var]])),
      kategori_kort = str_trunc(kategori_full, width = 25, ellipsis = "\u2026"),
      # Fullständigt (ej avkortat) kategorinamn i hover, samt vilka år som
      # ingår i summeringen.
      tooltip_text  = paste0(kategori_full, "<br>",
                             format_varde_matt(varde, matt), "<br>",
                             "\u00c5r: ", ar_text)
    )

  # Diagrammets x-axel visar kategori (inte år), så de valda åren läggs till
  # i rubriken för att göra tydligt vilken period stapeln avser.
  titel_med_ar <- paste0(titel, " år ", ar_text)

  ggplot(plot_data, aes(x = reorder(kategori_kort, varde), y = varde,
                        tooltip = tooltip_text, data_id = kategori_full)) +
    geom_col_interactive(fill = farg) +
    coord_flip() +
    labs(title = titel_med_ar, x = x_lab, y = y_lab_matt(matt), caption = KALLA_TEXT) +
    tema_rd_diagram() +
    skala_y_tal() +
    theme(legend.position = "none")
}
