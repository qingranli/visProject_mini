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
dt <- dt %>% 
  filter(Date <= peak_date) %>% 
  mutate(day_num = as.numeric(difftime(Date,peak_date+(1-day_of_year),units = "days")))

rm(temp_soil,peak,temp,model)

year_input = c(2000:2021) # min = 1937
dt.plot <- dt %>% filter(Year %in% year_input)
p0 <- ggplot(dt.plot, aes(x=day_num,y=temp_soil,group=Year)) + 
  geom_path(color="mistyrose2", size = 1.5) + 
  xlab("day of the year (1st Jan = 0)") + ylab("soil temperature (Celsius)") +
  scale_x_continuous(breaks = seq(0,133,10), limits = c(0,133)) +
  theme_light() + theme(panel.grid = element_blank()) +
  geom_image(data = dt.plot %>% filter(Date == peak_date),
             aes(x=day_num,y = temp_soil,
                 image="./dataDir/cherry_blossom_icon.png"),
             size = 0.05, asp = 1.9) + 
  geom_text(data = dt.plot %>% filter(Date == peak_date), 
            aes(x=day_num+12, y = temp_soil,
                label = peak_date),
            color = "indianred3",size = 5)

# animate: transitioning between years
p1 <-  p0 + transition_states(Year) + 
  ggtitle("Year = {closest_state}") +
  enter_appear() + exit_fade() + 
  theme(plot.title = element_text(face = "bold"))

anim1 <- animate(p1, nframe = 170, width = 800, height = 450,
                 end_pause = 30)
anim_save("Rplot_animate_peak.gif", anim1)
print("animation saved")
