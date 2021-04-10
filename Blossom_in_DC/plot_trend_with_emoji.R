# plot time series with end point as emoji

getwd()

library(data.table)
library(tidyverse)
library(ggplot2)
library(ggimage)

rm(list=ls())
gc()

peak <- fread("./dataDir/blossom_peak_date.csv")
temp <- fread("./dataDir/DC_temp_Airport.csv")

# predict soil temperature using the model built ====================
load("./dataDir/model_poly4.RData")
temp_soil <- predict(model,air_temp = temp$TMID)




# extract time series from a year ===================================
pt_peak <- peak$peak_date[which(peak$Year == 2021)]

dt_temp <- temp %>% select(DATE,TMID) %>% 
  mutate(Date = as.Date(DATE, format = "%m/%d/%Y")) %>%
  mutate(Year = year(Date)) %>% 
  filter(Year == 2021) %>% 
  filter(Date <= pt_peak) %>%
  select(Date,TMID)

n = dim(dt_temp)[1]
p0 <- ggplot(dt_temp, aes(x=Date,y=TMID)) + 
  geom_path(color="mistyrose2", size = 2) + 
  xlab("") + ylab("temperature (Celsius)") +
  scale_x_date(date_breaks = "2 weeks",
               date_minor_breaks = "1 week",
               date_labels = "%b-%d",
               limits = c(dt_temp$Date[1],dt_temp$Date[1]+133)) + 
  theme_light() + theme(panel.grid = element_blank())
p0

# add icon as end point
p1 <- p0 + geom_image(aes(x=dt_temp$Date[n],
                          y = dt_temp$TMID[n],
                          image="./cherry_blossom_icon.png"),
                          size = 0.07, asp = 1.9) + 
  geom_text(aes(x=dt_temp$Date[n]+7, 
                y = dt_temp$TMID[n]-2.7,
                label = pt_peak),color = "indianred3")
p1
