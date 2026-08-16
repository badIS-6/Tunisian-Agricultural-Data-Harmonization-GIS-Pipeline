####################### CONVERSION OF CLEAN DATA INTO GIS LAYERS ###################
####################### Badis Zammouri & Mohamed Chandoul

library(sp)
library(rgdal)

DATA_FOLDER <- "/home/badiss/Desktop/Internship 2026/Forests/Clean data"
OUTPUT_FOLDER <- "/home/badiss/Desktop/Internship 2026/Forests/GIS Layers"

SHAPEFILE <- "/home/badiss/Desktop/Internship 2026/Tunisia_regions/Tunisia_regions.shp"

dir.create(OUTPUT_FOLDER, recursive = TRUE, showWarnings = FALSE)

###################### loading shapefiles
shape <- readOGR(
  dsn = dirname(SHAPEFILE),
  layer = tools::file_path_sans_ext(basename(SHAPEFILE)),
  verbose = FALSE
)

if (!"region_id" %in% names(shape@data)) {
  shape@data$region_id <- 1:nrow(shape@data)
}

base_ids <- shape@data$region_id

files <- list.files(DATA_FOLDER, "\\.csv$", full.names = TRUE)

for (f in files) {
  
  df <- read.csv(f, stringsAsFactors = FALSE)
  names(df) <- tolower(names(df))
  
  # must contain region_id
  if (!"region_id" %in% names(df)) {
    next
  }
  
  df$region_id <- as.integer(df$region_id)
  
  #matching IDs
  valid_ids <- intersect(base_ids, df$region_id)
  
  if (length(valid_ids) == 0) next
  
  shape_sub <- shape[shape@data$region_id %in% valid_ids, ]
  
  df <- df[df$region_id %in% valid_ids, ]
  
  shape_sub <- shape_sub[order(shape_sub@data$region_id), ]
  df <- df[order(df$region_id), ]
  
  #building attributes
  shape_sub@data <- shape_sub@data
  
  cols <- setdiff(names(df), "region_id")
  
  for (col in cols) {
    vec <- df[[col]]
    names(vec) <- df$region_id
    shape_sub@data[[col]] <- vec[shape_sub@data$region_id]
  }
  
#output
  out_name <- paste0(
    tools::file_path_sans_ext(basename(f)),
    "_id_fixed"
  )
  
  writeOGR(
    obj = shape_sub,
    dsn = OUTPUT_FOLDER,
    layer = out_name,
    driver = "ESRI Shapefile",
    overwrite_layer = TRUE
  )
}

