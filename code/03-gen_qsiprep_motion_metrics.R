library(dplyr)
library(purrr)
library(readr)
library(tidyr)

tay_dwi_metrics <-
    list.files(path = "/archive/data/TAY/pipelines/in_progress/baseline/qsiprep",
               pattern = ".*desc-ImageQC_dwi.csv",
               recursive = TRUE,
               full.names = TRUE) %>%
    map_df(function(x) read_csv(x) %>% mutate(filename = gsub(".csv", "", basename(x)))) %>%
    select(filename, everything()) %>%
    separate(filename, into = c("subject", "session"), sep = "_", remove = TRUE)

tay_dwi_metrics %>%
    write_csv("../data/qsiprep_metrics.csv")
