library(tidyverse)
library(ndjson)
library(lubridate)
library(corporaexplorer)
library(purrr)
#library(disk.frame)



validate("./data/articles_2019-01-01.json")

files <- list.files(path = "./data", 
                    pattern = "*.json", 
                    full.names = TRUE, 
                    recursive = FALSE)

tidy_json <- NA

json_to_df <- function(file) {
    x <- stream_in(file, cls = "tbl")
    x <- x %>% select(publish_date, title, starts_with("paragraphs")) %>% 
      unite(., "Text", 3:ncol(.), 
            na.rm = TRUE, remove = TRUE, sep = " ") %>% 
      rename(., Title = title, Date = publish_date, Text = Text)
    tidy_json <- rbind(x, tidy_json) 
}

system.time(tidy_json <- map_df(files, json_to_df))
tidy_json$Date <- as.Date(tidy_json$Date)
tidy_json <- tidy_json %>% na.omit()

tidy_json_sample <- slice_sample(tidy_json, n = 2500)

#run_document_extractor(wapo)

wapo <- prepare_data(tidy_json_sample)

explore(wapo)

saveRDS(wapo, "saved_corporaexplorerobject.rds", compress = FALSE)

