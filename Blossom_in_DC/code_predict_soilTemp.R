# Using air temperature to predict soil temperature.
# daily sensor data 2002 to 2021

getwd()
setwd("./dataDir")

library(data.table)
library(tidyverse)
library(ggplot2)
library(caret)

rm(list=ls())
# dev.off()
gc()

soilDT = fread("Powder_Mill_soil_data.csv")
glimpse(soilDT)
summary(soilDT)

# # remove summer months July - Sept
soilDT <- soilDT %>%
  mutate(mon = month(Date)) %>%
  filter(mon %in% c(1,2,3,4,5,6,10,11,12)) %>% 
  filter(!is.na(temp_air), !is.na(temp_soil_20))

# plot Air temperature vs. Soil temperature (-20 inches)
p0 <- ggplot(soilDT, aes(x = temp_air, y = temp_soil_20)) + 
  geom_point(color = "cornflowerblue", alpha = 0.3, shape = 20) + 
  labs(title = "Relationship between air temperature and soil temperature (-20 inches)") +
  xlab("air temperature (Celsius)") + ylab("soil temperature (Celsius)") +
  theme_light() + theme(panel.grid = element_blank())
p0

# fitting a polynomial to the data (without CV) =====================
model <- lm(temp_soil_20 ~ poly(temp_air, degree = 3), data = soilDT)
summary(model)
coeff = round(model$coefficients,1)
regEq = paste0("SoilTemp =",coeff[1],"+",coeff[2],"(x)",
              "+",coeff[3],"(x2)","",coeff[4],"(x3), where x = AirTemp")
print(regEq)
# save model
save(model,file = "model_poly3.RData")

# prediction
predictions <- model %>% predict(soilDT[,c("temp_air")])

# plot fitted line
p1 <- p0 + geom_line(aes(y = predictions), size = 1.4)+
  labs(subtitle = regEq)
p1

png('Rplot_polyReg3_result.png',width = 600,height = 400)
p1
dev.off()

#####################################################################
# model selection: 5-fold cross validation
# The K-fold cross-validation method evaluates the model performance 
# on different subset of the training data and then calculate the 
# average RMSE.

# without using R package -------------------------------------------
#Randomly shuffle the data
set.seed(4921)
dt<-soilDT[sample(nrow(soilDT)),]

#Create 5 equally size folds
folds <- cut(seq(1,nrow(dt)),breaks=5,labels=FALSE)
RMSE_save = data.frame(degree=NA,RMSE=NA)

for(k in 1:7){ # for degree k perform 5-fold CV
  sum = 0
  for(i in 1:5){
    #Segment data by fold using the which() function 
    trainID <- which(folds==i,arr.ind=TRUE)
    train.dt <- dt[-trainID, ]
    test.dt <- dt[trainID, ]
    # polynomial regression on training data
    model = lm(temp_soil_20 ~ poly(temp_air, degree = k), 
               data = train.dt)
    # compute RMSE on test data
    predictions <- model %>% predict(test.dt)
    sum = sum + RMSE(predictions, test.dt$temp_soil_20)
  }
  RMSE_save = rbind(RMSE_save,
                    data.frame(degree=k,RMSE=sum/5))
}

p2 <- ggplot(RMSE_save[-1,], aes(x=degree,y=RMSE))+
  geom_line(size = 1.4) + 
  geom_label(aes(label = round(RMSE,3)))+
  scale_x_continuous(breaks = c(1:7)) +
  labs(title = "average RMSE (5-fold Cross-Validation)",
       subtitle = "soilTemp ~ poly(airTemp, degree = k)")+
  xlab("degree of polynomial, k") + ylab("")+
  theme_light() + theme(panel.grid = element_blank())
p2
png('Rplot_RMSE_5fold_CV.png',width = 600,height = 400)
p2
dev.off()

# with R package "caret" --------------------------------------------
# Define training control (5-fold CV)
set.seed(7412)
train.control <- trainControl(method = "cv", number = 5)
dt <- soilDT %>% select(temp_air,temp_soil_20)
# Train the model (varying degree of polynomial)
model_cv <- train(temp_soil_20 ~  poly(temp_air, degree = 3), 
                  data = dt, method = "lm",
                  trControl = train.control)
# save results
k = length(model_cv$coefnames)
result_cv = model_cv$results %>% 
  mutate(degree = k) %>% 
  select(degree,RMSE,Rsquared,MAE)
print(result_cv)
