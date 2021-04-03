# Using air temperature to predict soil temperature.
# daily sensor data 2002 to 2021

getwd()
setwd("./dataDir")

library(data.table)
library(tidyverse)
library(ggplot2)

rm(list=ls())
# dev.off()
gc()

soilDT = fread("Powder_Mill_soil_data.csv")
glimpse(soilDT)
summary(soilDT)

# remove summer months July - Sept
soilDT <- soilDT %>% 
  mutate(mon = month(Date)) %>% 
  filter(mon %in% c(1,2,3,4,5,6,10,11,12))

# plot Air temperature vs. Soil temperature (-20 inches)
p0 <- ggplot(soilDT, aes(x = temp_air, y = temp_soil_20)) + 
  geom_point(color = "cornflowerblue", alpha = 0.3, shape = 20) + 
  labs(title = "Relationship between air temperature and soil temperature (-20 inches)") +
  xlab("air temperature (Celsius)") + ylab("soil temperature (Celsius)") +
  theme_light() + theme(panel.grid = element_blank())
p0

# fitting a polynomial to the data (without CV)
model <- lm(temp_soil_20 ~ poly(temp_air, degree = 3), 
            data = soilDT %>% filter(!is.na(temp_air)))
summary(model)

# prediction
soil_fit <- model %>% predict(soilDT[,c("temp_air")])

# plot fitted line
p1 <- p0 + geom_line(aes(y = soil_fit), size = 1.4)
p1
