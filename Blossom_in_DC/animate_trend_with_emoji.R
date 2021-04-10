# plot time series with end point as emoji
# and animate the timeline

getwd()

library(data.table)
library(tidyverse)
library(ggplot2)
library(ggimage)
library(gganimate)

rm(list=ls())
gc()

peak <- fread("./dataDir/blossom_peak_date.csv")
temp <- fread("./dataDir/DC_temp_Airport.csv") %>% 
  mutate(temp_air = TMID)

# predict soil temperature using the model built ====================
load("model_poly4.RData")
temp_soil <- model %>% predict(temp[,'temp_air'])
temp <- temp %>% 
  mutate(temp_soil = temp_soil)

# format date =======================================================
dt_temp <- temp %>% 
  mutate(Date = as.Date(DATE, format = "%m/%d/%Y"),
         Year = year(Date)) %>% 
  filter(Year %in% peak$Year) %>% 
  select(Date,Year,temp_soil)

# extract time series before peak_date ==============================
dt <- merge(dt_temp,peak, by = "Year", all.x = TRUE)
dt <- dt %>% filter(Date <= peak_date) %>% 
  mutate(Year = factor(Year), 
         day_num = difftime(Date,
                            peak_date+(1-day_of_year), 
                            units = "days"))

rm(peak,temp,model)

year_input = 2000
p0 <- ggplot(dt %>% filter(Year == year_input), 
             aes(x=day_num,y=temp_soil,group = Year)) + 
  geom_path(color="mistyrose2", size = 2) + 
  xlab("day of the year (1st Jan = 0)") + ylab("soil temperature (Celsius)") +
  scale_x_continuous(breaks = seq(0,133,10), limits = c(0,133)) +
  theme_light() + theme(panel.grid = element_blank())
p0

# add icon as end point
dt1 <- dt %>% filter(Year == year_input) %>% filter(Date == peak_date)
p1 <- p0 + geom_image(aes(x=dt1$day_num,
                          y = dt1$temp_soil,
                          image="./dataDir/cherry_blossom_icon.png"),
                          size = 0.05, asp = 1.9) + 
  geom_text(aes(x=dt1$day_num+12, y = dt1$temp_soil,
                label = dt1$peak_date),
            color = "indianred3")
p1

png("Rplot_2021_peak.png",width = 8,height = 4.5,units = "in",res=100)
p1
dev.off()
