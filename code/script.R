#### objective: visualize gun ownership and murders by state



#### about the data
# This data is provided by the U.S. Census Bureau and the FBI, and is decribed here:
# http://en.wikipedia.org/wiki/Gun_violence_in_the_United_States_by_state



#### set working directory
rm(list = ls())
getwd()
#setwd('C:/Users/Desk 1/Desktop/guns_murders_states')
setwd('/Users/hawooksong/Desktop/r_visualization/guns_murders_states')
dir()


#### plot a map of the U.S.
library(ggplot2)  # for map_data() function
statesMap <- map_data('state')
head(statesMap)

ggplot(statesMap, aes(x = long, y = lat, group = group)) +
  geom_polygon(fill = 'white', color = 'black') +
  coord_map('mercator')
dev.copy(png, './figures/0_basic_map.png', width = 480, height = 280)
dev.off()



#### load and view guns/murders data
murders <- read.csv('./data/murders.csv')
head(murders)



#### comparing two data sets
unique(statesMap$region)
unique(murders$State)
# note that Alaska and Hawaii are missing from statesMap$region



#### merge 'statesMap' and 'murders' data frames
# merge by a common variable: 'region' from statesMap dataset and 'State' from murders dataset
str(statesMap)
str(murders)

# create a new variable for merge key
murders$region <- tolower(murders$State)

# merging
data <- merge(statesMap, murders, by = 'region')
head(data)

# checking for successful merge and consistency
unique(data$region == tolower(data$State))

# removing unnecessary (duplicate) variable
str(data$State)
unique(data$State)
data <- subset(data, select = - State)



#### plot a map of murders
ggplot(data, aes(x = long, y = lat, group = group, fill = Murders)) + 
  geom_polygon(color = 'black') +
  scale_fill_gradient(low = 'white', high = 'red', guide = 'legend') +
  coord_map('mercator')
dev.copy(png, './figures/1_map_of_murders.png', width = 480, height = 280)
dev.off()



#### plot a map of population
ggplot(data, aes(x = long, y = lat, group = group, fill = Population)) +
  geom_polygon(color = 'black') + 
  scale_fill_gradient(low = 'white', high = 'red', guide = 'legend') +
  coord_map('mercator')
dev.copy(png, './figures/2_map_of_population.png', width = 480, height = 280)
dev.off()



#### plot a map of murder rates
data$MurderRate <- data$Murders / data$Population * 100000  # number of murders per 100000 residents
ggplot(data, aes(x = long, y = lat, group = group, fill = MurderRate)) +
  geom_polygon(color = 'black') +
  scale_fill_gradient(low = 'white', high = 'red', guide = 'legend') +
  coord_map('mercator')
dev.copy(png, './figures/3_map_of_murder_rates.png', width = 480, height = 280)
dev.off()



#### region (or state) where the murder rate is the higest and the lowest
range(data$MurderRate) 
rMurder <- sort(unique(data$MurderRate))
rMurder

murders$MurderRate <- murders$Murder / murders$Population * 100000

# region with the highest murder rate
as.character(murders[murders$MurderRate == max(rMurder), ]$State)

# region with the lowest murder rate
as.character(murders[murders$MurderRate == min(rMurder), ]$State)



#### plot a map of murder rates excluding District of Columbia
ggplot(subset(data, region != 'district of columbia'), 
       aes(x = long, y = lat, group = group, fill = MurderRate)) +
  geom_polygon(color = 'black') +
  scale_fill_gradient(low = 'white', high = 'red', guide = 'legend') + 
  coord_map('mercator')
dev.copy(png, './figures/4_map_of_murder_rates_without_DC.png', width = 480, height = 280)
dev.off()



#### plot a map of murder rates excluding District of Columbia (alternative method)
ggplot(data, aes(x = long, y = lat, group = group, fill = MurderRate)) + 
  geom_polygon(color = 'black') +
  scale_fill_gradient(low = 'white', high = 'red', guide = 'legend', limits = c(0.9, 10)) + 
  coord_map('mercator')



#### plot a map of murder rates (final)
ggplot(subset(data, region != 'district of columbia'), 
       aes(x = long, y = lat, group = group, fill = MurderRate)) +
  geom_polygon(color = 'black') +
  scale_fill_gradient(low = 'white', high = 'red', guide = 'legend') +
  xlab('longitude') + 
  ylab('latitude') +
  ggtitle('Murder Rate in the U.S. in 2010 \n by State (except Alaska and Hawaii)') + 
  guides(fill = guide_legend(title = 'Murders Per \n100,000')) +
  coord_map('mercator') 
dev.copy(png, './figures/5_map_of_murder_rates_final.png', width = 480, height = 300)
dev.off()



#### plot a map of gun ownership (final)
ggplot(data, aes(x = long, y = lat, group = group, fill = GunOwnership)) + 
  geom_polygon(color = 'black') + 
  scale_fill_gradient(low = 'white', high = 'orange', guide = 'legend') +
  xlab('longitude') + 
  ylab('latitude') + 
  ggtitle('Gun Ownership in the U.S. in 2007 \n by State (except Alaska and Hawaii)') +
  guides(fill = guide_legend(title = 'Percentage of \nGun Owners')) +  
  coord_map('mercator')
dev.copy(png, './figures/6_map_of_gun_ownership_final.png', width = 480, height = 300)  
dev.off()



#### region (or state) where gun ownership is most and least prevalent
murders[order(-murders$GunOwnership), c(1, 6)]



#### plot murder rate vs. gun ownership
# calculate the correlation coefficient and its p-value
cor.test(murders$GunOwnership, murders$MurderRate)$estimate
cor.test(murders$GunOwnership, murders$MurderRate)$p.value

# calculate the r^2
lm1 <- lm(MurderRate ~ GunOwnership, data = murders)
round(summary(lm1)$r.squared, 3)

# plot
ggplot(murders, aes(x = GunOwnership * 100, y = MurderRate)) + 
  geom_point() +
  stat_smooth(method = 'lm') + 
  xlab('gun ownership (%)') + 
  ylab('murder rate (per 100,000)') + 
  ggtitle('Scatter Plot: Gun Ownership (2007) and Murder Rate (2010) in the U.S.') 
dev.copy(png, './figures/7_scatter_plot_gun_ownership_vs_murder_rate.png')
dev.off()



#### plot murder rate vs. gun ownership graph without the outlier point from D.C.
# remove the outlier point from D.C.
murders2 <- subset(murders, State != 'District of Columbia')

# calculate the correlation coefficient and its p-value
cor.test(murders2$GunOwnership, murders2$MurderRate)$estimate
cor.test(murders2$GunOwnership, murders2$MurderRate)$p.value

# calculate the r^2
lm2 <- lm(MurderRate ~ GunOwnership, data = murders2)
round(summary(lm2)$r.squared, 3)

# plot murder rate vs. gun ownership
ggplot(murders2, aes(x = GunOwnership * 100, y = MurderRate)) + 
  geom_point() +
  stat_smooth(method = 'lm') + 
  xlab('gun ownership (%)') + 
  ylab('murder rate (per 100,000)') + 
  ggtitle('Scatter Plot: Gun Ownership (2007) and Murder Rate (2010) in the U.S.') 
dev.copy(png, './figures/8_scatter_plot_gun_ownership_vs_murder_rate_without_DC.png')
dev.off()

