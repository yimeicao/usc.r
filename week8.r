library(leaflet)
library(tidyverse)
install.packages("tidycensus")
library(tidycensus)
census_api_key("e0da4312438fa32962c28601708bdabbbf81882d", overwrite = FALSE, install = FALSE)
m90 <- get_decennial(geography = "state", variables = "H043A001", year = 1990)

# chart our rent data
m90 %>% 
  ggplot(aes(x = value, y = reorder(NAME, value))) +
  geom_point()

# get American Community Service data
transportation <- get_acs(geography = "state", variables = "B08006_008", geometry = FALSE, survey = "acs5", year = 2017)

# get more ACS data
transpo_total <- get_acs(geography = "state", variables = "B08006_001", geometry = FALSE, survey = "acs5", year = 2017)

# join our data
transportation <- transportation %>% left_join(transpo_total, by = "NAME")
transportation$rate <- transportation$estimate.x / transportation$estimate.y * 100

library(rgdal)
states <- readOGR("~/Desktop/Data Jour/tl_2019_us_state",
                  layer = "tl_2019_us_state", GDAL1_integer64_policy = TRUE)

states_with_rate <- sp::merge(states, transportation, by = "NAME")

qpal <- colorQuantile("PiYG", states_with_rate$rate, 9)


states_with_rate %>% leaflet() %>% addTiles() %>%
  addPolygons(weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 0.5,
              color = ~qpal(rate),
              highlightOptions = highlightOptions(color = "white", weight = 2,
                                                  bringToFront = TRUE))

v17 <- load_variables(2017, "acs5", cache = TRUE)

View(v17)

marriage <- get_acs(geography = "state", variables = "B12007_002", geometry = FALSE, survey = "acs5", year = 2017)

states_with_marriage <- sp::merge(states, marriage, by = "NAME")

qpal <- colorQuantile("PiYG", states_with_marriage$estimate, 9)

states_with_marriage %>% leaflet() %>% addTiles() %>%
  addPolygons(weight = 1, smoothFactor = 0.5, opacity = 1.0, fillOpacity = 0.5,
              color = ~qpal(estimate),
              highlightOptions = highlightOptions(color = "white", weight = 2,
                                                  bringToFront = TRUE))

