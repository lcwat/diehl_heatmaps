# this script walks through how to load behavioral data in a pipeline for aggregation

# Lucas Watson

# load libraries ---------------------------------------------------------

library(tidyverse) # for data cleaning and shaping
library(glue)      # for string manipulation
library(janitor)   # for cleaning variable names

# get data files ----------------------------------------------------------

# use list.files() to get folders and file names
folders <- list.files('data', full.names = T)

# loop over folders, grab files within, create dataset
for (folder in folders) {
  
  # list files within that folder
  files = list.files(folder, full.names = T)
  
  # print update to console
  print(glue('Loading folder {folder} ({which(folder == folders)}/{length(folders)})'))
  
  # remove files without ratIDs (observation recordings)
  files_to_use = files[!str_detect(files, '#\\d+') & !str_detect(files, '.sz') & !str_detect(files, 'observer')]
  
  # loop over files
  for (file in files_to_use) {
    
    # strip info from file name
    id = str_extract(file, '(?<=Rat )[A-Z]+\\d+-[A-Z]')
    test = as.numeric(str_extract(file, '(?<=test no)\\d+'))
    day = as.numeric(str_extract(file, '(?<=Day)\\d'))
    box = as.numeric(str_extract(file, '(?<=Box )\\d'))
    
    # load in file
    locs = read_csv(file, show_col_types = F)
    
    # make clean variable names
    colnames(locs) = make_clean_names(colnames(locs))
    
    # keep only time and positional values, add identifying info. 
    locs = locs |> 
      select(starts_with('time') | contains('position')) |> 
      add_column(
        rat_ID = id, 
        day = day, 
        test_no = test, 
        box = box, 
        .before = 1
      )
    
    # if file/folder is first, clean and keep this file, otherwise clean and append
    if (which(folder == folders) == 1 & which(file == files_to_use) == 1) {
      
      # separate beh and dreadds
      if (str_detect(id, 'BEH')) {
        beh_all_locs = locs
      }
      else {
        drd_all_locs = locs
      }
    }
    else {
      
      # append to master df
      
      # separate beh and dreadds
      if (str_detect(id, 'BEH')) {
        beh_all_locs = bind_rows(beh_all_locs, locs)
      }
      else if (str_detect(id, 'DRD') & !exists('drd_all_locs')){
        drd_all_locs = locs
      }
      else {
        drd_all_locs = bind_rows(drd_all_locs, locs)
      }
    }
  }
}

# final dataset created
summary(beh_all_locs)

# write final dataset to file
dir.create('data/clean')
write_csv(drd_all_locs, 'data/clean/all_drd_location_data.csv')
write_csv(beh_all_locs, 'data/clean/all_beh_location_data.csv')
