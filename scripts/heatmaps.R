# this script walks through how to generate heatmaps from aggregated location telemetry 
# data from a group of rats

# Lucas Watson

# load libraries ----------------------------------------------------------

library(tidyverse) # for loading, grouping, and visualizing data

# load data ---------------------------------------------------------------

# see scripts/load_and_clean_files.R for how I aggregated the data for each group
agg_files <- list.files('data/clean', full.names = T)

# load in files, I'm using their index position instead of writing cause I'm lazy
beh <- read_csv(agg_files[2])
drd <- read_csv(agg_files[3])

# get a quick summary to see what it looks like
summary(beh)
summary(drd)

beh |> 
  count(rat_ID, day, test_no, box) |> 
  arrange(test_no)

# heatmap -----------------------------------------------------------------

# our main workhorse is the stat_density_2D_filled() function
beh |> 
  ggplot(aes(x = centre_position_x, y = centre_position_y)) + 
  stat_density2d_filled() + 
  scale_fill_viridis_d(guide = 'none', option = 'magma') + 
  coord_fixed() + 
  theme_void() + 
  facet_wrap(~box)
