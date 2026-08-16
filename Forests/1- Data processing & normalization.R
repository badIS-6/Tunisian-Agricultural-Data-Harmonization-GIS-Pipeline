####################### NORMALIZATION OF DATASETS FOR GIS TRANSLATION ###################
####################### Badis Zammouri & Mohamed Chandoul

library(readr)
library(readxl)
library(janitor)
library(stringr)
library(stringdist)
library(purrr)
library(dplyr)

input_folder <- "/home/badiss/Desktop/Internship 2026/Forests/Raw data (ONAGRI)"
output_folder <- "/home/badiss/Desktop/Internship 2026/Forests/Clean data"

dir.create(output_folder, showWarnings = FALSE, recursive = TRUE)

##################### reference data
regions_ref <- read_csv(
  "/home/badiss/Desktop/Internship 2026/Tunisia.csv",
  show_col_types = FALSE
) %>%
  clean_names() %>%
  mutate(
    region_id = row_number(),
    name_ar = str_to_lower(name),
    name_fr = str_to_lower(french_name)
  )

############## language normalization
normalize_arabic <- function(x) {
  
  x <- as.character(x)
  
  x %>%
    str_replace_all("[إأآا]", "ا") %>%
    str_replace_all("ى", "ي") %>%
    str_replace_all("ة", "ه") %>%
    str_replace_all("[[:punct:]]", " ") %>%
    str_squish() %>%
    str_to_lower()
}

normalize_text <- function(x) {
  normalize_arabic(x)
}

#################### region matching
match_region <- function(x, ref) {
  
  if (is.na(x) || x == "") {
    return(NA_integer_)
  }
  
  x_clean <- normalize_text(x)
  
  exact <- ref %>%
    filter(
      normalize_text(name_ar) == x_clean |
        normalize_text(name_fr) == x_clean
    )
  
  if (nrow(exact) > 0) {
    return(exact$region_id[1])
  }
  
  score_ar <- stringdist(
    x_clean,
    normalize_text(ref$name_ar),
    method = "jw"
  )
  
  score_fr <- stringdist(
    x_clean,
    normalize_text(ref$name_fr),
    method = "jw"
  )
  
  score <- pmin(score_ar, score_fr)
  
  if (all(is.na(score))) {
    return(NA_integer_)
  }
  
  best <- which.min(score)
  
  if (!is.na(score[best]) && score[best] < 0.15) {
    return(ref$region_id[best])
  }
  
  NA_integer_
}

find_region_column <- function(df, ref) {
  
  text_cols <- names(df)[
    sapply(df, function(x)
      is.character(x) || is.factor(x))
  ]
  
  if (length(text_cols) == 0) {
    return(NA_character_)
  }
  
  best_col <- NA_character_
  best_score <- 0
  
  region_names <- c(
    normalize_text(ref$name_ar),
    normalize_text(ref$name_fr)
  )
  
  for (col in text_cols) {
    
    vals <- normalize_text(df[[col]])
    
    score <- sum(vals %in% region_names, na.rm = TRUE)
    
    if (score > best_score) {
      best_score <- score
      best_col <- col
    }
  }
  
  best_col
}

#################### reading the datasets
read_any <- function(path) {
  
  if (str_detect(path, "\\.csv$")) {
    return(read_csv(path, show_col_types = FALSE))
  }
  
  if (str_detect(path, "\\.xlsx$")) {
    return(read_excel(path))
  }
  
  stop("Unsupported format")
}

####################### processing a single dataset
process_dataset <- function(file_path) {
  
  cat("\nProcessing:", basename(file_path), "\n")
  
  df <- read_any(file_path) %>%
    clean_names()
  
  region_col <- find_region_column(df, regions_ref)
  
  if (is.na(region_col)) {
    
    cat("No region column detected\n")
    
    return(
      tibble(
        file = basename(file_path),
        rows = nrow(df),
        region_column = NA,
        matched = 0
      )
    )
  }
  
  df <- df %>%
    mutate(
      region_id = map_int(
        .data[[region_col]],
        ~ match_region(.x, regions_ref)
      )
    ) %>%
    left_join(
      regions_ref %>%
        select(
          region_id,
          matched_region_ar = name_ar,
          matched_region_fr = name_fr
        ),
      by = "region_id"
    )
  
  output_file <- file.path(
    output_folder,
    paste0(
      tools::file_path_sans_ext(
        basename(file_path)
      ),
      ".csv"
    )
  )
  
  write_csv(df, output_file)
  
  tibble(
    file = basename(file_path),
    rows = nrow(df),
    region_column = region_col,
    matched = sum(!is.na(df$region_id))
  )
}

###################### processing the whole batch
files <- list.files(
  input_folder,
  full.names = TRUE,
  pattern = "\\.(csv|xlsx)$"
)

summary <- bind_rows(
  lapply(files, function(f) {
    
    tryCatch(
      process_dataset(f),
      error = function(e) {
        
        cat(
          "\nERROR:",
          basename(f),
          "\n",
          e$message,
          "\n"
        )
        
        tibble(
          file = basename(f),
          rows = NA,
          region_column = NA,
          matched = NA
        )
      }
    )
    
  })
)

##################### processing summary
write_csv(
  summary,
  file.path(output_folder, "processing_summary.csv")
)
print(summary)

