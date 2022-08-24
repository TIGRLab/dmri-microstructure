'''Qsiprep metrics extraction

Usage:
    03-gen_qsiprep_motion_metrics.R  <qsiprep_file_path>  <csv_output_path>
    
    Arguments:
    <qsiprep_file_path>  Path to directory holding subject folders from Qsiprep outputs
    <csv_output_path>    Path to write qsiprep metrics to
''' -> doc


library(dplyr)
library(purrr)
library(readr)
library(tidyr)
library(docopt)

arguments <- docopt(doc)
qsiprep_file_path <- arguments$qsiprep_file_path
csv_output_path <- arguments$csv_output_path
metric_extraction(qsiprep_file_path,csv_output_path)

metric_extraction <- function(qsiprep_file_path,csv_output_path){
    dwi_metrics <-
        list.files(path = qsiprep_file_path,
                pattern = ".*desc-ImageQC_dwi.csv",
                recursive = TRUE,
                full.names = TRUE) %>%
        map_df(function(x) read_csv(x) %>% mutate(filename = gsub(".csv", "", basename(x)))) %>%
        select(filename, everything()) %>%
        separate(filename, into = c("subject", "session"), sep = "_", remove = TRUE)

    dwi_metrics %>%
        write_csv(csv_output_path)
}
