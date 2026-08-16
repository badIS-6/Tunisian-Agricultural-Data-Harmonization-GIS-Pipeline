####################### CONVERSION OF CLEAN DATA INTO GIS LAYERS ###################
####################### Badis Zammouri & Mohamed Chandoul

library(sp)
library(rgdal)

DATA_FOLDER <- "/home/badiss/Desktop/Internship 2026/Animal production/Clean data"
OUTPUT_FOLDER <- "/home/badiss/Desktop/Internship 2026/Animal production/GIS Layers"

SHAPEFILE <- "/home/badiss/Desktop/Internship 2026/Tunisia_regions/Tunisia_regions.shp"

dir.create(OUTPUT_FOLDER, recursive = TRUE, showWarnings = FALSE)

###################### LOAD SHAPEFILE
shape <- readOGR(
  dsn = dirname(SHAPEFILE),
  layer = tools::file_path_sans_ext(basename(SHAPEFILE)),
  verbose = FALSE
)

# ensure stable ID
if (!"region_id" %in% names(shape@data)) {
  shape@data$region_id <- 1:nrow(shape@data)
}

base_shape <- shape  # keep immutable reference

###################### CLEAN FIELD NAMES (CRITICAL FOR GDAL)
clean_names <- function(x) {
  x <- tolower(x)
  x <- gsub("[^a-z0-9]", "_", x)
  x <- substr(x, 1, 10)
  make.unique(x)
}

files <- list.files(DATA_FOLDER, "\\.csv$", full.names = TRUE)

for (f in files) {
  
  df <- read.csv(f, stringsAsFactors = FALSE)
  names(df) <- tolower(names(df))
  
  if (!"region_id" %in% names(df)) next
  
  df$region_id <- as.integer(df$region_id)
  
  valid_ids <- intersect(base_shape@data$region_id, df$region_id)
  if (length(valid_ids) == 0) next
  
  shape_sub <- base_shape[base_shape@data$region_id %in% valid_ids, ]
  
  df <- df[df$region_id %in% valid_ids, ]
  
  shape_sub <- shape_sub[order(shape_sub@data$region_id), ]
  df <- df[order(df$region_id), ]
  
  n <- nrow(shape_sub@data)
  
  new_data <- data.frame(region_id = shape_sub@data$region_id)
  
  cols <- setdiff(names(df), "region_id")
  
  for (col in cols) {
    
    vec <- df[[col]]
    names(vec) <- df$region_id
    
    new_data[[col]] <- vec[shape_sub@data$region_id]
  }
  
  names(new_data) <- clean_names(names(new_data))
  
  shape_sub@data <- new_data
  
  out_name <- paste0(
    tools::file_path_sans_ext(basename(f)),
    "_fixed"
  )
  
  writeOGR(
    obj = shape_sub,
    dsn = OUTPUT_FOLDER,
    layer = out_name,
    driver = "ESRI Shapefile",
    overwrite_layer = TRUE
  )
}
