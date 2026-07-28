## Globala inställningar för Shinyappen: regionala_utvecklingsmedel

# Ladda nödvändiga paket
library(shiny)
library(shinyjs)
library(shinyWidgets)
library(DT)
library(ggiraph)
library(dplyr)
library(tidyr)
library(readr)
library(ggplot2)
library(lubridate)

# innehåller kopplingar till databaserna, ink lösenord som ska konfigureras: source("https://raw.githubusercontent.com/Region-Dalarna/funktioner/main/func_shinyappar.R", encoding = "utf-8", echo = FALSE)

# Funkar inte med min R-version. source("https://raw.githubusercontent.com/Region-Dalarna/funktioner/main/func_API.R", encoding = "utf-8")

# Allmänna options - TRUE = visa inte R-felmeddelanden i appen, FALSE = visa felmeddelanden från R på webben
options(shiny.sanitize.errors = FALSE)

# Läs in data från projektmappen
data_trans    <- readRDS("data/data_trans_clean.rds")
data_adresser <- readRDS("data/data_adresser_clean.rds")
data_finans   <- readRDS("data/data_finans_clean.rds")
