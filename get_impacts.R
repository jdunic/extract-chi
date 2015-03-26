library(raster)
library(beepr)

imp_map <- raster('Data/CI_2013_OneTimePeriod/global_cumul_impact_2013_all_layers.tif')

#imp_map_longlat <- projectRaster(imp_map, crs = "+proj=lonlat +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs")
plot(imp_map, col = c('#8AB4EB', '#B2D698', '#F7EE3B', '#F0B81F', '#E67D27', '#991118'))
beep()

projection(imp_map)

#extract(imp_map, test_vals, buffer = 1000)

# The global human cumulative impact map (full model layer)

# Read in the tif file as an object with the formal class 'RasterLayer'
#imp_map <- raster("model_class_wgs84_lzw.tif")

# Alternatively we can read in the geotiff with each band as an individual 
# raster. This allows us to extract the RGB data from each 'band'
# See an iterative solution here: http://stackoverflow.com/questions/15270107/r-get-a-specific-band-of-a-rasterlayer
imp_map_b1 <- raster("../Human_Cumulative_Impacts/model_class_wgs84_lzw.tif", band = 1)
imp_map_b2 <- raster("../Human_Cumulative_Impacts/model_class_wgs84_lzw.tif", band = 2)
imp_map_b3 <- raster("../Human_Cumulative_Impacts/model_class_wgs84_lzw.tif", band = 3)

# We can subsequently combine these into a stack which allows us to plot using 
# the RGB colour scheme.
imp_stack <- stack(imp_map_b1, imp_map_b2, imp_map_b3)
plotRGB(imp_stack)

# Check the projection just to be sure it's WGS84
projection(imp_stack)

# Test coordinates, with impact level eye-balled off the halpern map and points
# taken off google maps.
# I do not assign a projection because they are coming from google, which uses
# the WGS84 (EPSG: 4326) CRS. 
# Our meta-analysis data will also be assumed to use the WGS84 (EPSG: 4326) 
# unless otherwise stated in the paper, given that this is standard for most GPS
# units.
imp_level <- c('very low', 'low', 'medium', 'very high', 'land', 'sf_land', 'sf_bay')
lat <- c(-74.903173,  -6.680232,  18.728598, 58.438787, 45.213004, 37.22158,  38.065723)
long <- c(-45.068090, -105.823552, -110.122704, -0.357954, -116.556702, -122.202644, -122.392813)
test_vals <- data.frame("imp_level" = imp_level, "lat" = lat, "long" = long)
# Convert test_vals into a spatial object
# The assignments specifies which columns have your c(lat, long)
coordinates(test_vals) <- c(3, 2)
projection(test_vals) <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

# Extracts the RGB values from the three data layers. 
# The 'land' test values return NA only. 
impl <- extract(imp_map, test_vals, buffer = 2000, small = T)
impl

impl <- extract(imp_stack, test_vals, buffer = 2000, small = T)
impl


# Plot the raster stack with the test values. Use plotRGB to plot the rgb 
# defined colours stored in the different bands. 
plotRGB(imp_stack)
plotRGB(imp_stack, colNA = 'black')
points(test_vals)

# Plot raster stack on an existing plot to set limits on the size 
# (there may be a better way but I don't know what it is)
#plot(c(-170, 10), c(-90, 90), type='n', axes=F, xlab='', ylab='')
plotRGB(imp_stack, add = TRUE)


plot(c(-170, 10), c(-90, 90), type='n', axes=F, xlab='', ylab='')
plotRGB(rgb,add=T)


#########
# California Current Data
#########
cal_map <- raster("full_self_calc.tif")

# Check the projection just to be sure it's WGS84
projection(cal_map)

# More eye-balled test values, a bit harder to tell so the categories could be
# off. 
imp_level <- c('high', 'med?', 'med_low?', 'low', 'sf_land', 'near_land')
lat <- c(37.068328, 46.83765, 27.722436, 29.187903, 37.22158,  37.871516)
long <- c(-122.443056, -124.883308, -117.560577, -115.000528, -122.202644, -122.572542)
test_vals <- data.frame("imp_level" = imp_level, "lat" = lat, "long" = long)
coordinates(test_vals) <- c(3, 2)

cal_imps <- extract(cal_map, test_vals, buffer = 100, small = T)
# Yay! the land values are just NA. The others meanwhile look pretty good.
cal_imps


cal_imps_1000 <- extract(cal_map, test_vals, buffer = 1000, small = T)
cal_imps_1000

cal_imps_2000 <- extract(cal_map, test_vals, buffer = 2000, small = T)
# Once we extend the buffer to be 2 km, the nearshore/onshore point gets one 
# value.
cal_imps_2000


# I think there is more that can be done with this list, but I haven't dealt
# with it yet. 