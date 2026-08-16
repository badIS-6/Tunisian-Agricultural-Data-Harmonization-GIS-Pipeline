
library(tidyverse)
library(readr)
library(readxl)
library(openxlsx)
library(stringi)
library(stringdist)
library(purrr)
library(fs)
library(janitor)

options(
  stringsAsFactors = FALSE,
  scipen = 999
)


# ============================================================
# 1. BASE DIRECTORY
# ============================================================

BASE_DIR <- "/home/badisz/Desktop/Smart SDG Tunisia/ONAGRI Data pipeline"


# ============================================================
# 2. INPUT CATEGORIES
# ============================================================

CATEGORIES <- c(
  "Forests",
  "Animal production",
  "Rainfall",
  "Agricultural products",
  "Dams & Irrigated areas",
  "Land development"
)


# ============================================================
# 3. AUTOMATIC INPUT / OUTPUT PATHS
# ============================================================

CLEAN_DATA_DIRS <- file.path(
  BASE_DIR,
  CATEGORIES,
  "Clean data"
)

OUTPUT_DIRS <- file.path(
  BASE_DIR,
  CATEGORIES,
  "Clean_data_1"
)


# ============================================================
# 4. REFERENCE DIRECTORY
# ============================================================
#
# IMPORTANT:
#
# The authoritative reference dataset should be placed in
# this directory.
#
# If your reference file is elsewhere, change this path.
#
# The script will search recursively for CSV/XLSX/XLS files
# and identify the most likely canonical geographical column.
# ============================================================

REFERENCE_DIR <- file.path(
  BASE_DIR,
  "Reference"
)


# ============================================================
# 5. DRY RUN
# ============================================================
#
# TRUE:
#   Analyze everything and create reports only.
#
# FALSE:
#   Actually write standardized datasets into Clean_data_1.
# ============================================================

DRY_RUN <- TRUE


# ============================================================
# 6. MATCHING PARAMETERS
# ============================================================

FUZZY_THRESHOLD <- 0.90

FUZZY_MARGIN <- 0.03

SAMPLE_SIZE <- 10

MAX_TRANSFORMATION_EXAMPLES <- 30


# ============================================================
# 7. VALIDATE CATEGORY DIRECTORIES
# ============================================================

cat("\n")
cat("============================================================\n")
cat("CHECKING CATEGORY DIRECTORIES\n")
cat("============================================================\n\n")

for (i in seq_along(CATEGORIES)) {
  
  category <- CATEGORIES[i]
  
  input_dir <- CLEAN_DATA_DIRS[i]
  
  output_dir <- OUTPUT_DIRS[i]
  
  cat("Category:", category, "\n")
  cat("Input :", input_dir, "\n")
  cat("Output:", output_dir, "\n")
  
  if (!dir_exists(input_dir)) {
    
    warning(
      paste0(
        "Input directory does not exist: ",
        input_dir
      )
    )
    
  } else {
    
    cat("Input directory: OK\n")
  }
  
  if (!DRY_RUN) {
    
    if (!dir_exists(output_dir)) {
      
      dir_create(
        output_dir,
        recurse = TRUE
      )
    }
    
    cat("Output directory: OK\n")
    
  } else {
    
    cat(
      "Output directory: not created because DRY_RUN = TRUE\n"
    )
  }
  
  cat("\n")
}


# ============================================================
# 8. CHECK REFERENCE DIRECTORY
# ============================================================

if (!dir_exists(REFERENCE_DIR)) {
  
  stop(
    paste0(
      "\nREFERENCE_DIR does not exist:\n",
      REFERENCE_DIR,
      "\n\n",
      "Create the reference directory or change REFERENCE_DIR ",
      "to the location containing your authoritative reference ",
      "dataset."
    )
  )
}


# ============================================================
# 9. FIND SUPPORTED FILES
# ============================================================

find_supported_files <- function(directory) {
  
  if (!dir_exists(directory)) {
    return(character(0))
  }
  
  files <- fs::dir_ls(
    directory,
    recurse = TRUE,
    type = "file",
    regexp = "\\.(csv|xlsx|xls)$",
    ignore.case = TRUE
  )
  
  sort(files)
}


# ============================================================
# 10. READ DATASET
# ============================================================

read_dataset <- function(file_path) {
  
  extension <- tolower(
    fs::path_ext(file_path)
  )
  
  result <- tryCatch({
    
    if (extension == "csv") {
      
      data <- readr::read_csv(
        file_path,
        show_col_types = FALSE,
        progress = FALSE,
        name_repair = "unique"
      )
      
    } else if (
      extension %in% c("xlsx", "xls")
    ) {
      
      data <- readxl::read_excel(
        file_path,
        sheet = 1,
        .name_repair = "unique"
      )
      
    } else {
      
      stop(
        "Unsupported file type."
      )
    }
    
    as.data.frame(data)
    
  }, error = function(e) {
    
    if (extension == "csv") {
      
      tryCatch({
        
        data <- readr::read_csv(
          file_path,
          locale = locale(
            encoding = "Latin1"
          ),
          show_col_types = FALSE,
          progress = FALSE,
          name_repair = "unique"
        )
        
        as.data.frame(data)
        
      }, error = function(e2) {
        
        stop(
          paste0(
            "Could not read file.\n",
            "UTF-8 error: ",
            e$message,
            "\n",
            "Latin1 error: ",
            e2$message
          )
        )
      })
      
    } else {
      
      stop(e$message)
    }
  })
  
  result
}


# ============================================================
# 11. NORMALIZE COLUMN NAMES
# ============================================================

normalize_column_name <- function(x) {
  
  x <- as.character(x)
  
  x <- stringi::stri_trans_nfc(x)
  
  x <- stringi::stri_trans_general(
    x,
    "Latin-ASCII"
  )
  
  x <- tolower(x)
  
  x <- gsub(
    "[^a-z0-9]",
    "",
    x
  )
  
  x
}


# ============================================================
# 12. NORMALIZE REGION VALUES
# ============================================================

normalize_region <- function(x) {
  
  x <- as.character(x)
  
  x <- stringi::stri_trans_nfc(x)
  
  x[is.na(x)] <- ""
  
  x <- stringr::str_trim(x)
  
  x <- stringr::str_replace_all(
    x,
    "\\s+",
    " "
  )
  
  x <- stringr::str_to_lower(x)
  
  # Normalize apostrophes
  x <- stringr::str_replace_all(
    x,
    "[’‘`´]",
    "'"
  )
  
  # Normalize dashes
  x <- stringr::str_replace_all(
    x,
    "[‐-‒–—−]",
    "-"
  )
  
  # Remove accents
  x <- stringi::stri_trans_general(
    x,
    "Latin-ASCII"
  )
  
  # Remove geographical prefixes for matching
  prefix_patterns <- c(
    "^gouvernorat\\s+de\\s+",
    "^gouvernorat\\s+du\\s+",
    "^gouvernorat\\s+d[' ]",
    "^gouvernorat\\s+des\\s+",
    "^governorate\\s+of\\s+",
    "^governorate\\s+de\\s+",
    "^governorate\\s+du\\s+",
    "^wilaya\\s+de\\s+",
    "^wilaya\\s+du\\s+"
  )
  
  for (pattern in prefix_patterns) {
    
    x <- stringr::str_replace(
      x,
      pattern,
      ""
    )
  }
  
  # Remove Tunisia / Tunisie suffix
  x <- stringr::str_replace(
    x,
    "\\s*,?\\s*(tunisia|tunisie)$",
    ""
  )
  
  # Normalize punctuation
  x <- stringr::str_replace_all(
    x,
    "[,;:/_|]+",
    " "
  )
  
  x <- stringr::str_replace_all(
    x,
    "-",
    " "
  )
  
  x <- stringr::str_replace_all(
    x,
    "[^a-z0-9' ]",
    " "
  )
  
  x <- stringr::str_replace_all(
    x,
    "'",
    ""
  )
  
  x <- stringr::str_replace_all(
    x,
    "\\s+",
    " "
  )
  
  x <- stringr::str_trim(x)
  
  x
}


# ============================================================
# 13. GEOGRAPHICAL COLUMN DETECTION
# ============================================================

GEOGRAPHICAL_COLUMN_PATTERNS <- c(
  "region",
  "regions",
  "gouvernorat",
  "gouvernorats",
  "governorate",
  "governorates",
  "wilaya",
  "province",
  "localisation",
  "location"
)


get_column_name_score <- function(
    column_name) {
  
  normalized <-
    normalize_column_name(
      column_name
    )
  
  if (
    normalized %in%
    GEOGRAPHICAL_COLUMN_PATTERNS
  ) {
    return(1)
  }
  
  if (
    any(
      stringr::str_detect(
        normalized,
        paste(
          GEOGRAPHICAL_COLUMN_PATTERNS,
          collapse = "|"
        )
      )
    )
  ) {
    return(0.6)
  }
  
  0
}


score_reference_column <- function(
    data,
    column_name) {
  
  values <- as.character(
    data[[column_name]]
  )
  
  values <- values[
    !is.na(values) &
      trimws(values) != ""
  ]
  
  if (length(values) == 0) {
    return(0)
  }
  
  name_score <-
    get_column_name_score(
      column_name
    )
  
  unique_values <-
    unique(values)
  
  cardinality_score <- if (
    length(unique_values) >= 4 &&
    length(unique_values) <= 100
  ) {
    1
  } else if (
    length(unique_values) > 100 &&
    length(unique_values) <= 500
  ) {
    0.5
  } else {
    0
  }
  
  text_score <- mean(
    stringr::str_detect(
      values,
      "[A-Za-zÀ-ÿ]"
    )
  )
  
  (
    name_score * 0.55
  ) +
    (
      cardinality_score * 0.25
    ) +
    (
      text_score * 0.20
    )
}


find_reference_file <- function(
    reference_files) {
  
  candidates <- list()
  
  for (file_path in reference_files) {
    
    data <- tryCatch(
      read_dataset(file_path),
      error = function(e) NULL
    )
    
    if (is.null(data)) {
      next
    }
    
    for (column in names(data)) {
      
      score <-
        score_reference_column(
          data,
          column
        )
      
      candidates[
        [length(candidates) + 1]
      ] <-
        tibble(
          file = file_path,
          column = column,
          score = score
        )
    }
  }
  
  if (length(candidates) == 0) {
    
    stop(
      "No possible reference column was found."
    )
  }
  
  candidate_table <-
    bind_rows(candidates) %>%
    arrange(desc(score))
  
  cat("\nREFERENCE CANDIDATES\n")
  print(candidate_table)
  
  best <-
    candidate_table[1, ]
  
  if (best$score < 0.45) {
    
    stop(
      paste0(
        "\nCould not confidently identify the ",
        "authoritative geographical reference column."
      )
    )
  }
  
  if (
    nrow(candidate_table) >= 2 &&
    best$score -
    candidate_table$score[2] <
    0.10
  ) {
    
    stop(
      paste0(
        "\nReference detection is ambiguous.\n",
        "Best candidate: ",
        best$file,
        " / ",
        best$column,
        "\n"
      )
    )
  }
  
  list(
    file = best$file,
    column = best$column,
    score = best$score
  )
}


# ============================================================
# 14. DETECT GEOGRAPHICAL COLUMNS
# ============================================================

detect_region_columns <- function(
    data,
    reference_values) {
  
  reference_keys <- unique(
    normalize_region(
      reference_values
    )
  )
  
  reference_keys <- reference_keys[
    reference_keys != ""
  ]
  
  results <- list()
  
  for (column in names(data)) {
    
    values <- as.character(
      data[[column]]
    )
    
    non_empty <- values[
      !is.na(values) &
        trimws(values) != ""
    ]
    
    if (length(non_empty) == 0) {
      next
    }
    
    column_name_score <-
      get_column_name_score(
        column
      )
    
    normalized_values <-
      normalize_region(
        non_empty
      )
    
    exact_overlap <- mean(
      normalized_values %in%
        reference_keys
    )
    
    text_ratio <- mean(
      stringr::str_detect(
        non_empty,
        "[A-Za-zÀ-ÿ]"
      )
    )
    
    detection_score <-
      (
        column_name_score * 0.50
      ) +
      (
        exact_overlap * 0.40
      ) +
      (
        text_ratio * 0.10
      )
    
    results[
      [length(results) + 1]
    ] <-
      tibble(
        column = column,
        column_name_score =
          column_name_score,
        reference_overlap =
          exact_overlap,
        text_ratio =
          text_ratio,
        detection_score =
          detection_score
      )
  }
  
  if (length(results) == 0) {
    return(tibble())
  }
  
  bind_rows(results) %>%
    arrange(
      desc(detection_score)
    ) %>%
    filter(
      detection_score >= 0.45
    )
}


# ============================================================
# 15. SIMILARITY
# ============================================================

calculate_similarity <- function(
    x,
    y) {
  
  if (
    is.na(x) ||
    is.na(y) ||
    x == "" ||
    y == ""
  ) {
    return(0)
  }
  
  distance <-
    stringdist::stringdist(
      x,
      y,
      method = "jw",
      p = 0.1
    )
  
  similarity <- 1 - distance
  
  max(
    0,
    min(
      1,
      similarity
    )
  )
}


# ============================================================
# 16. BEST MATCH
# ============================================================

find_best_match <- function(
    value,
    reference_table,
    threshold = FUZZY_THRESHOLD,
    margin = FUZZY_MARGIN) {
  
  normalized_value <-
    normalize_region(value)
  
  if (
    is.na(value) ||
    trimws(
      as.character(value)
    ) == "" ||
    normalized_value == ""
  ) {
    
    return(
      tibble(
        original_value =
          as.character(value),
        normalized_value =
          normalized_value,
        standardized_value =
          as.character(value),
        match_method =
          "none",
        similarity_score =
          NA_real_,
        status =
          "unmatched",
        best_candidate =
          NA_character_,
        reason =
          "Empty or missing value"
      )
    )
  }
  
  
  # ----------------------------------------------------------
  # NORMALIZED EXACT MATCH
  # ----------------------------------------------------------
  
  exact_matches <-
    reference_table %>%
    filter(
      normalized_reference ==
        normalized_value
    )
  
  if (
    nrow(exact_matches) == 1
  ) {
    
    return(
      tibble(
        original_value =
          as.character(value),
        normalized_value =
          normalized_value,
        standardized_value =
          exact_matches$canonical_name[1],
        match_method =
          "normalized",
        similarity_score =
          1,
        status =
          "normalized_match",
        best_candidate =
          exact_matches$canonical_name[1],
        reason =
          "Exact match after normalization"
      )
    )
  }
  
  
  # ----------------------------------------------------------
  # AMBIGUOUS REFERENCE KEY
  # ----------------------------------------------------------
  
  if (
    nrow(exact_matches) > 1
  ) {
    
    return(
      tibble(
        original_value =
          as.character(value),
        normalized_value =
          normalized_value,
        standardized_value =
          as.character(value),
        match_method =
          "none",
        similarity_score =
          1,
        status =
          "ambiguous",
        best_candidate =
          paste(
            exact_matches$canonical_name,
            collapse = " | "
          ),
        reason =
          "Multiple canonical names have the same normalized key"
      )
    )
  }
  
  
  # ----------------------------------------------------------
  # FUZZY MATCH
  # ----------------------------------------------------------
  
  similarities <- map_dbl(
    reference_table$normalized_reference,
    ~ calculate_similarity(
      normalized_value,
      .x
    )
  )
  
  order_idx <- order(
    similarities,
    decreasing = TRUE
  )
  
  best_idx <- order_idx[1]
  
  best_score <-
    similarities[best_idx]
  
  second_score <- if (
    length(order_idx) >= 2
  ) {
    similarities[
      order_idx[2]
    ]
  } else {
    0
  }
  
  best_candidate <-
    reference_table$canonical_name[
      best_idx
    ]
  
  
  # ----------------------------------------------------------
  # UNSAFE FUZZY MATCH
  # ----------------------------------------------------------
  
  if (
    best_score <
    threshold
  ) {
    
    return(
      tibble(
        original_value =
          as.character(value),
        normalized_value =
          normalized_value,
        standardized_value =
          as.character(value),
        match_method =
          "none",
        similarity_score =
          best_score,
        status =
          "unmatched",
        best_candidate =
          best_candidate,
        reason =
          paste0(
            "Best similarity ",
            round(
              best_score,
              4
            ),
            " below threshold ",
            threshold
          )
      )
    )
  }
  
  
  # ----------------------------------------------------------
  # AMBIGUOUS FUZZY MATCH
  # ----------------------------------------------------------
  
  if (
    (
      best_score -
      second_score
    ) <
    margin
  ) {
    
    second_candidate <-
      reference_table$canonical_name[
        order_idx[2]
      ]
    
    return(
      tibble(
        original_value =
          as.character(value),
        normalized_value =
          normalized_value,
        standardized_value =
          as.character(value),
        match_method =
          "fuzzy",
        similarity_score =
          best_score,
        status =
          "ambiguous",
        best_candidate =
          paste(
            best_candidate,
            second_candidate,
            sep = " | "
          ),
        reason =
          paste0(
            "Best and second-best candidates are too close: ",
            round(
              best_score,
              4
            ),
            " vs ",
            round(
              second_score,
              4
            )
          )
      )
    )
  }
  
  
  # ----------------------------------------------------------
  # SAFE FUZZY MATCH
  # ----------------------------------------------------------
  
  tibble(
    original_value =
      as.character(value),
    normalized_value =
      normalized_value,
    standardized_value =
      best_candidate,
    match_method =
      "fuzzy",
    similarity_score =
      best_score,
    status =
      "fuzzy_match",
    best_candidate =
      best_candidate,
    reason =
      paste0(
        "Fuzzy similarity accepted: ",
        round(
          best_score,
          4
        )
      )
  )
}


# ============================================================
# 17. STANDARDIZE ONE COLUMN
# ============================================================

standardize_region_column <- function(
    data,
    column_name,
    source_file,
    reference_table) {
  
  original_values <-
    as.character(
      data[[column_name]]
    )
  
  unique_values <-
    unique(
      original_values
    )
  
  unique_values <-
    unique_values[
      !is.na(unique_values) &
        trimws(unique_values) != ""
    ]
  
  cat(
    "    Unique values:",
    length(unique_values),
    "\n"
  )
  
  match_table <- map_dfr(
    unique_values,
    ~ find_best_match(
      .x,
      reference_table
    )
  )
  
  match_table <-
    match_table %>%
    mutate(
      source_file =
        source_file,
      column =
        column_name,
      .before = 1
    )
  
  
  # ----------------------------------------------------------
  # REPLACE ONLY SAFE MATCHES
  # ----------------------------------------------------------
  
  safe_lookup <-
    match_table %>%
    filter(
      status %in%
        c(
          "normalized_match",
          "fuzzy_match"
        )
    ) %>%
    select(
      original_value,
      standardized_value
    )
  
  
  if (
    nrow(safe_lookup) > 0
  ) {
    
    replacement_map <-
      setNames(
        safe_lookup$standardized_value,
        safe_lookup$original_value
      )
    
    new_values <-
      original_values
    
    idx <-
      original_values %in%
      names(replacement_map)
    
    new_values[idx] <-
      unname(
        replacement_map[
          original_values[idx]
        ]
      )
    
    data[[column_name]] <-
      new_values
  }
  
  
  list(
    data =
      data,
    report =
      match_table
  )
}


# ============================================================
# 18. SAVE DATASET
# ============================================================

save_dataset <- function(
    data,
    output_path) {
  
  extension <-
    tolower(
      fs::path_ext(
        output_path
      )
    )
  
  
  if (
    extension == "csv"
  ) {
    
    readr::write_csv(
      data,
      output_path,
      na = ""
    )
    
  } else if (
    extension == "xlsx"
  ) {
    
    openxlsx::write.xlsx(
      data,
      output_path,
      overwrite = TRUE
    )
    
  } else if (
    extension == "xls"
  ) {
    
    # R does not reliably write legacy XLS.
    # Save as XLSX instead.
    
    xlsx_output <-
      paste0(
        fs::path_ext_remove(
          output_path
        ),
        ".xlsx"
      )
    
    openxlsx::write.xlsx(
      data,
      xlsx_output,
      overwrite = TRUE
    )
    
  } else {
    
    stop(
      paste0(
        "Unsupported extension: ",
        extension
      )
    )
  }
}


# ============================================================
# 19. PROCESS ONE FILE
# ============================================================

process_dataset <- function(
    file_path,
    reference_values,
    reference_table) {
  
  cat(
    "\n------------------------------------------------------------\n"
  )
  
  cat(
    "FILE:",
    basename(file_path),
    "\n"
  )
  
  data <-
    read_dataset(
      file_path
    )
  
  cat(
    "Rows:",
    nrow(data),
    "\n"
  )
  
  cat(
    "Columns:",
    ncol(data),
    "\n"
  )
  
  
  region_columns <-
    detect_region_columns(
      data,
      reference_values
    )
  
  
  if (
    nrow(region_columns) == 0
  ) {
    
    cat(
      "No geographical column detected.\n"
    )
    
    return(
      list(
        data =
          data,
        report =
          tibble(),
        detected_columns =
          character(0),
        success =
          TRUE,
        error =
          NULL
      )
    )
  }
  
  
  cat(
    "Geographical columns detected:\n"
  )
  
  print(
    region_columns %>%
      select(
        column,
        detection_score
      )
  )
  
  
  all_reports <-
    list()
  
  processed_data <-
    data
  
  
  for (
    column_name in
    region_columns$column
  ) {
    
    cat(
      "\n  Standardizing:",
      column_name,
      "\n"
    )
    
    result <-
      standardize_region_column(
        processed_data,
        column_name,
        basename(file_path),
        reference_table
      )
    
    processed_data <-
      result$data
    
    all_reports[
      [length(all_reports) + 1]
    ] <-
      result$report
  }
  
  
  report <- if (
    length(all_reports) > 0
  ) {
    
    bind_rows(
      all_reports
    )
    
  } else {
    
    tibble()
  }
  
  
  list(
    data =
      processed_data,
    report =
      report,
    detected_columns =
      region_columns$column,
    success =
      TRUE,
    error =
      NULL
  )
}


# ============================================================
# 20. PROCESS ONE CATEGORY
# ============================================================

process_category <- function(
    category,
    input_dir,
    output_dir,
    reference_values,
    reference_table) {
  
  cat("\n\n")
  cat("############################################################\n")
  cat("CATEGORY:", category, "\n")
  cat("############################################################\n")
  
  if (
    !dir_exists(input_dir)
  ) {
    
    cat(
      "SKIPPED: input directory does not exist.\n"
    )
    
    return(
      list(
        reports = list(),
        failed = list(),
        files_found = 0,
        files_processed = 0,
        rows = 0,
        geo_columns = 0
      )
    )
  }
  
  
  files <-
    find_supported_files(
      input_dir
    )
  
  
  cat(
    "Files found:",
    length(files),
    "\n"
  )
  
  
  if (
    length(files) == 0
  ) {
    
    cat(
      "No supported files found.\n"
    )
    
    return(
      list(
        reports = list(),
        failed = list(),
        files_found = 0,
        files_processed = 0,
        rows = 0,
        geo_columns = 0
      )
    )
  }
  
  
  if (!DRY_RUN) {
    
    dir_create(
      output_dir,
      recurse = TRUE
    )
  }
  
  
  reports <-
    list()
  
  failed <-
    list()
  
  files_processed <-
    0
  
  total_rows <-
    0
  
  total_geo_columns <-
    0
  
  
  for (
    i in seq_along(files)
  ) {
    
    file_path <-
      files[i]
    
    cat(
      "\n[",
      i,
      "/",
      length(files),
      "] ",
      basename(file_path),
      "\n",
      sep = ""
    )
    
    
    result <-
      tryCatch(
        
        process_dataset(
          file_path,
          reference_values,
          reference_table
        ),
        
        error = function(e) {
          
          list(
            data =
              NULL,
            report =
              tibble(),
            detected_columns =
              character(0),
            success =
              FALSE,
            error =
              e$message
          )
        }
      )
    
    
    if (
      !result$success
    ) {
      
      cat(
        "ERROR:",
        result$error,
        "\n"
      )
      
      failed[
        [length(failed) + 1]
      ] <-
        list(
          file =
            file_path,
          error =
            result$error
        )
      
      next
    }
    
    
    files_processed <-
      files_processed + 1
    
    total_rows <-
      total_rows +
      nrow(result$data)
    
    total_geo_columns <-
      total_geo_columns +
      length(
        result$detected_columns
      )
    
    
    if (
      nrow(result$report) > 0
    ) {
      
      reports[
        [length(reports) + 1]
      ] <-
        result$report
    }
    
    
    # --------------------------------------------------------
    # SAVE STANDARDIZED FILE
    # --------------------------------------------------------
    
    if (!DRY_RUN) {
      
      relative_path <-
        fs::path_rel(
          file_path,
          start = input_dir
        )
      
      output_path <-
        file.path(
          output_dir,
          relative_path
        )
      
      output_parent <-
        dirname(
          output_path
        )
      
      dir_create(
        output_parent,
        recurse = TRUE
      )
      
      save_dataset(
        result$data,
        output_path
      )
      
      cat(
        "  SAVED:",
        output_path,
        "\n"
      )
      
    } else {
      
      cat(
        "  DRY RUN: file not written.\n"
      )
    }
  }
  
  
  list(
    reports =
      reports,
    failed =
      failed,
    files_found =
      length(files),
    files_processed =
      files_processed,
    rows =
      total_rows,
    geo_columns =
      total_geo_columns
  )
}


# ============================================================
# 21. LOAD AUTHORITATIVE REFERENCE
# ============================================================

cat("\n")
cat("============================================================\n")
cat("LOADING AUTHORITATIVE REFERENCE DATA\n")
cat("============================================================\n")


reference_files <-
  find_supported_files(
    REFERENCE_DIR
  )


if (
  length(reference_files) == 0
) {
  
  stop(
    paste0(
      "No CSV/XLSX/XLS files found in:\n",
      REFERENCE_DIR
    )
  )
}


cat(
  "Reference files found:",
  length(reference_files),
  "\n"
)


reference_info <-
  find_reference_file(
    reference_files
  )


cat(
  "\nSelected reference file:\n",
  reference_info$file,
  "\n"
)

cat(
  "Selected canonical geographical column:\n",
  reference_info$column,
  "\n"
)


reference_data <-
  read_dataset(
    reference_info$file
  )


reference_values <-
  as.character(
    reference_data[
      [reference_info$column]
    ]
  )


reference_values <-
  reference_values[
    !is.na(reference_values) &
      trimws(reference_values) != ""
  ]


reference_values <-
  unique(
    reference_values
  )


if (
  length(reference_values) < 2
) {
  
  stop(
    "The reference geographical column contains fewer than 2 valid values."
  )
}


cat(
  "\nCanonical geographical names:",
  length(reference_values),
  "\n\n"
)

print(
  reference_values
)


# ============================================================
# 22. CREATE REFERENCE LOOKUP
# ============================================================

reference_table <-
  tibble(
    canonical_name =
      reference_values
  ) %>%
  mutate(
    normalized_reference =
      normalize_region(
        canonical_name
      )
  )


duplicate_reference_keys <-
  reference_table %>%
  group_by(
    normalized_reference
  ) %>%
  filter(
    n() > 1
  ) %>%
  ungroup()


if (
  nrow(duplicate_reference_keys) > 0
) {
  
  cat(
    "\nWARNING: Duplicate normalized reference keys:\n"
  )
  
  print(
    duplicate_reference_keys
  )
}


# ============================================================
# 23. PROCESS ALL SIX CATEGORIES
# ============================================================

cat("\n")
cat("============================================================\n")
cat("STARTING ALL CATEGORY PROCESSING\n")
cat("============================================================\n")


category_results <-
  list()


for (
  i in seq_along(CATEGORIES)
) {
  
  category <-
    CATEGORIES[i]
  
  input_dir <-
    CLEAN_DATA_DIRS[i]
  
  output_dir <-
    OUTPUT_DIRS[i]
  
  
  category_results[
    [category]
  ] <-
    process_category(
      category =
        category,
      input_dir =
        input_dir,
      output_dir =
        output_dir,
      reference_values =
        reference_values,
      reference_table =
        reference_table
    )
}


# ============================================================
# 24. COMBINE REPORTS
# ============================================================

all_reports <-
  list()

all_failed <-
  list()


for (
  category in
  names(category_results)
) {
  
  result <-
    category_results[
      [category]
    ]
  
  if (
    length(result$reports) > 0
  ) {
    
    category_report <-
      bind_rows(
        result$reports
      ) %>%
      mutate(
        category =
          category,
        .before = 1
      )
    
    all_reports[
      [length(all_reports) + 1]
    ] <-
      category_report
  }
  
  
  if (
    length(result$failed) > 0
  ) {
    
    all_failed[
      [length(all_failed) + 1]
    ] <-
      tibble(
        category =
          category,
        file =
          map_chr(
            result$failed,
            "file"
          ),
        error =
          map_chr(
            result$failed,
            "error"
          )
      )
  }
}


final_report <- if (
  length(all_reports) > 0
) {
  
  bind_rows(
    all_reports
  )
  
} else {
  
  tibble()
}


# ============================================================
# 25. SAVE REPORTS PER CATEGORY
# ============================================================

for (
  category in CATEGORIES
) {
  
  result <-
    category_results[
      [category]
    ]
  
  output_dir <-
    OUTPUT_DIRS[
      CATEGORIES == category
    ]
  
  
  if (
    length(result$reports) > 0
  ) {
    
    category_report <-
      bind_rows(
        result$reports
      )
    
    
    unmatched <-
      category_report %>%
      filter(
        status %in%
          c(
            "unmatched",
            "ambiguous"
          )
      )
    
    
    if (!DRY_RUN) {
      
      dir_create(
        output_dir,
        recurse = TRUE
      )
      
      write_csv(
        category_report,
        file.path(
          output_dir,
          "region_standardization_report.csv"
        ),
        na = ""
      )
      
      write_csv(
        unmatched,
        file.path(
          output_dir,
          "unmatched_regions.csv"
        ),
        na = ""
      )
      
    } else {
      
      report_dir <-
        file.path(
          output_dir,
          "DRY_RUN_REPORTS"
        )
      
      dir_create(
        report_dir,
        recurse = TRUE
      )
      
      write_csv(
        category_report,
        file.path(
          report_dir,
          "region_standardization_report.csv"
        ),
        na = ""
      )
      
      write_csv(
        unmatched,
        file.path(
          report_dir,
          "unmatched_regions.csv"
        ),
        na = ""
      )
    }
  }
}


# ============================================================
# 26. GLOBAL SUMMARY
# ============================================================

cat("\n")
cat("============================================================\n")
cat("FINAL PIPELINE SUMMARY\n")
cat("============================================================\n\n")


summary_table <-
  map_dfr(
    CATEGORIES,
    function(category) {
      
      result <-
        category_results[
          [category]
        ]
      
      tibble(
        category =
          category,
        files_found =
          result$files_found,
        files_processed =
          result$files_processed,
        rows =
          result$rows,
        geographical_columns =
          result$geo_columns,
        failed =
          length(result$failed)
      )
    }
  )


print(
  summary_table
)


# ============================================================
# 27. GLOBAL REPORT
# ============================================================

if (
  nrow(final_report) > 0
) {
  
  if (!DRY_RUN) {
    
    write_csv(
      final_report,
      file.path(
        BASE_DIR,
        "region_standardization_global_report.csv"
      ),
      na = ""
    )
    
  } else {
    
    write_csv(
      final_report,
      file.path(
        BASE_DIR,
        "region_standardization_global_report_DRY_RUN.csv"
      ),
      na = ""
    )
  }
}


# ============================================================
# 28. GLOBAL UNMATCHED REPORT
# ============================================================

if (
  nrow(final_report) > 0
) {
  
  global_unmatched <-
    final_report %>%
    filter(
      status %in%
        c(
          "unmatched",
          "ambiguous"
        )
    )
  
  
  if (!DRY_RUN) {
    
    write_csv(
      global_unmatched,
      file.path(
        BASE_DIR,
        "unmatched_regions_global.csv"
      ),
      na = ""
    )
    
  } else {
    
    write_csv(
      global_unmatched,
      file.path(
        BASE_DIR,
        "unmatched_regions_global_DRY_RUN.csv"
      ),
      na = ""
    )
  }
}


# ============================================================
# 29. MATCHING SUMMARY
# ============================================================

if (
  nrow(final_report) > 0
) {
  
  cat(
    "\nMATCHING STATUS\n"
  )
  
  print(
    final_report %>%
      count(
        status,
        sort = TRUE
      )
  )
  
  
  changed_values <-
    final_report %>%
    filter(
      status %in%
        c(
          "normalized_match",
          "fuzzy_match"
        ),
      original_value !=
        standardized_value
    )
  
  
  cat(
    "\nValues changed:",
    nrow(changed_values),
    "\n"
  )
  
  
  cat(
    "Unmatched:",
    sum(
      final_report$status ==
        "unmatched",
      na.rm = TRUE
    ),
    "\n"
  )
  
  
  cat(
    "Ambiguous:",
    sum(
      final_report$status ==
        "ambiguous",
      na.rm = TRUE
    ),
    "\n"
  )
}


# ============================================================
# 30. FINAL MESSAGE
# ============================================================

cat("\n")
cat("============================================================\n")
cat("PIPELINE FINISHED\n")
cat("============================================================\n\n")


if (DRY_RUN) {
  
  cat(
    "DRY_RUN = TRUE\n\n"
  )
  
  cat(
    "No standardized datasets were written.\n"
  )
  
  cat(
    "Review the DRY_RUN_REPORTS directories first.\n\n"
  )
  
  cat(
    "After validation, change:\n\n"
  )
  
  cat(
    "DRY_RUN <- FALSE\n\n"
  )
  
  cat(
    "Then rerun the entire script.\n"
  )
  
} else {
  
  cat(
    "Standardized datasets were written into:\n\n"
  )
  
  for (
    category in CATEGORIES
  ) {
    
    cat(
      "  ",
      file.path(
        BASE_DIR,
        category,
        "Clean_data_1"
      ),
      "\n",
      sep = ""
    )
  }
  
  cat(
    "\nGlobal reports were written to:\n\n"
  )
  
  cat(
    "  ",
    BASE_DIR,
    "\n",
    sep = ""
  )
}
