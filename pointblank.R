# Explore options using {pointblank} for some of the validation steps 
# necessary when importing user datasets
# Attempts to duplicate the functions in validate.R


# get some typical data with errors for testing
raw_dat <- read.csv("data-raw/westerband_2022_wdate.csv")
subset_dat <- raw_dat[, c(1, 3, 4)]

mapped_dat <- map_fields(subset_dat)

errors <- data.frame(specificEpithet = "Not species", 
                     decimalLatitude = -91, 
                     decimalLongitude = 181)
errors_dat <- rbind(mapped_dat, errors)

# option 1
# validate directly on dataframe, print errors to console
errors_dat |>
  pointblank::col_vals_between(columns = decimalLatitude,
                               left = -90,
                               right = 90, 
                               actions = pointblank::warn_on_fail()) |> 
  pointblank::col_vals_between(columns = decimalLongitude, 
                               left = -180, 
                               right = 180, 
                               actions = pointblank::warn_on_fail())

# option 2
# scan the dataset and produce a summary
# could be useful for identifying NAs?
scanned_dat <- pointblank::scan_data(errors_dat, sections = "OM")  
  
