## Prepare and Install required libraries and packages 

install.packages("dplR", dependencies=TRUE)  #Only for the first time and comment it.
install.packages("dplR") # For dendrochronological analysis

##Load the data

spruce <- read.rwl("BBOB1.rwl")   # Norway spruce
douglas <- read.rwl("BBOB4.rwl")  # Douglas fir
oak <- read.rwl("BBOB6.rwl")      # Pedunculate oak


stc <- c(5, 2, 1) #Differentiates and decodes the naming scheme til the core level

"
Eg: stc vector For BBOB101G typically identify the components as
5 characters for site and species (Eg: BBOB1 for Norway spruce)
2 for tree(Eg: 01 ) 
1 for core ID (Eg: O or G )
" 

# Parse IDs for each dataset

spruce_ids <- read.ids(spruce, stc=stc )
douglas_ids <- read.ids(douglas, stc=stc)
oak_ids <- read.ids(oak, stc=stc )


# Mean of individual tree species data with NA values included

spruce_tm <- treeMean(spruce,spruce_ids,na.rm=TRUE)
douglas_tm <- treeMean(douglas,douglas_ids,na.rm=TRUE)
oak_tm <- treeMean(oak,oak_ids,na.rm=TRUE)


##GLK (>.5 -> Good)

# glk.legacy(spruce_tm)
# glk.legacy(douglas_tm)
# glk.legacy(oak_tm)

#All Values looks above 0.5

# mean(glk.legacy(spruce_tm), na.rm = TRUE) # Mean GLK = 0.707
# mean(glk.legacy(douglas_tm), na.rm = TRUE) #Mean GLK = 0.656
# mean(glk.legacy(oak_tm), na.rm = TRUE) Mean GLK = 0.691

##Inter-series co relation for three species

# s_cor_tm <- cor(spruce_tm, use = "pairwise.complete")
# s_cor_tm <- cor_tm[upper.tri(cor_tm)]
# mean(s_cor_tm)
# # 0.3213275
# 
# d_cor_tm <- cor(douglas_tm, use = "pairwise.complete")
# d_cor_tm <- d_cor_tm[upper.tri(d_cor_tm)]
# mean(d_cor_tm)
# #   0.3455743
# 
# o_cor_tm <- cor(oak_tm, use = "pairwise.complete")
# o_cor_tm <- o_cor_tm[upper.tri(o_cor_tm)]
# mean(o_cor_tm)
# #   0.3381279

#??treeMean
#colours()


#------------------  detrending  -------------------#

#detrending methods
# i.detrend(spruce_tm)
# i.detrend(douglas_tm)
# i.detrend(oak_tm)

spruce_d <- detrend(spruce_tm,method = "Spline",nyrs =32)
#spruce_d

douglas_d <- detrend(douglas_tm,method = "Spline",nyrs =32)
#douglas_d

oak_d <- detrend(oak_tm,method = "Spline",nyrs =32)
#oak_d


spag.plot(spruce_tm)
spag.plot(spruce_d)
#spag.plot(oak_d)



##------------- Resilience for 2003 and 1976 for spruce -----------

#install.packages("pointRes") #Only for the first time and comment it.
library(pointRes)

spruce_res <- res.comp(spruce_d)
#spruce_res

spruce_resist <- spruce_res$resist
spruce_recov <- spruce_res$recov
spruce_resil <- spruce_res$resil


spruce_years<- as.numeric(rownames(spruce_resist))
spruce_years

spruce_resist_2003 <- spruce_resist[spruce_years==2003, ]
spruce_recov_2003 <- spruce_recov[spruce_years==2003, ]
spruce_resil_2003 <- spruce_resil[spruce_years==2003, ]


spruce_resist_1976 <- spruce_resist[spruce_years==1976, ]
spruce_recov_1976 <- spruce_recov[spruce_years==1976, ]
spruce_resil_1976 <- spruce_resil[spruce_years==1976, ]

##------------- Resilience for 2003 and 1976 for douglas -----------

douglas_res <- res.comp(douglas_d)
#douglas_res

douglas_resist <- douglas_res$resist
douglas_recov <- douglas_res$recov
douglas_resil <- douglas_res$resil


douglas_years<- as.numeric(rownames(douglas_resist))
#douglas_years

douglas_resist_2003 <- douglas_resist[douglas_years==2003, ]
douglas_recov_2003 <- douglas_recov[douglas_years==2003, ]
douglas_resil_2003 <- douglas_resil[douglas_years==2003, ]

douglas_resist_1976 <- douglas_resist[douglas_years==1976, ]
douglas_recov_1976 <- douglas_recov[douglas_years==1976, ]
douglas_resil_1976 <- douglas_resil[douglas_years==1976, ]

##------------- Resilience for 2003 and 1976 for oak -----------

oak_res <- res.comp(oak_d)
#oak_res

oak_resist <- oak_res$resist
oak_recov <- oak_res$recov
oak_resil <- oak_res$resil


oak_years<- as.numeric(rownames(oak_resist))
#oak_years

oak_resist_2003 <- oak_resist[oak_years==2003, ]
oak_recov_2003 <- oak_recov[oak_years==2003, ]
oak_resil_2003 <- oak_resil[oak_years==2003, ]

oak_resist_1976 <- oak_resist[oak_years==1976, ]
oak_recov_1976 <- oak_recov[oak_years==1976, ]
oak_resil_1976 <- oak_resil[oak_years==1976, ]

#---------------------- Shows the Difference in resilience using Box Plot-----------------------------

# Difference in Resilience for the 3 species in 1976

par(mfrow = c(1, 1))
boxplot(spruce_resil_1976,douglas_resil_1976,oak_resil_1976,
        main="1976",
        col = c("azure3","coral1","cadetblue"),
        names = c("spruce","douglas","oak"),
        ylab="Resilience")



# Difference in Resilience for the 3 species in 2003

par(las=1)
boxplot(spruce_resil_2003,douglas_resil_2003,oak_resil_2003,
        main="2003",
        col = c("azure3","coral1","cadetblue"),
        names = c("spruce","douglas","oak"),
        ylab="Resilience")


# par(las=1)
# boxplot(spruce_resist_2003,douglas_resist_2003,oak_resist_2003,
#         col = c("green","orange","blue"),
#         names = c("spruce","douglas","oak"),
#         ylab="resistance")
# par(las=1)
# boxplot(spruce_recov_2003,douglas_recov_2003,oak_recov_2003,
#         col = c("green","orange","blue"),
#         names = c("spruce","douglas","oak"),
#         ylab="Recovery")


# 
# boxplot(spruce_resist_1976,douglas_resist_1976,oak_resist_1976,
#         col = c("green","orange","blue"),
#         names = c("spruce","douglas","oak"),
#         ylab="resistance")
# 
# boxplot(spruce_recov_1976,douglas_recov_1976,oak_recov_1976,
#         col = c("green","orange","blue"),
#         names = c("spruce","douglas","oak"),
#         ylab="Recovery")


##--------------- tests ----------------------------

#Shapiro test to check if the data is distributed normally or not

shapiro.test(spruce_resil)
shapiro.test(douglas_resil)
shapiro.test(oak_resil)
#p-value is less forall => not normally distributed => non-parametric test


# ------- Wilcox test  for 1976 ------ #

# Wilcoxon test between spruce and Douglas
wilcox.test(spruce_resil_1976, douglas_resil_1976) 

# Wilcoxon test between spruce and oak
wilcox.test(spruce_resil_1976, oak_resil_1976)

# Wilcoxon test between douglas and oak
wilcox.test(douglas_resil_1976, oak_resil_1976)



# -------  Wilcox test  for 2003  ------ # 

wilcox.test(spruce_resil_2003, douglas_resil_2003)

# Wilcoxon test between spruce and oak
wilcox.test(spruce_resil_2003, oak_resil_2003)

# Wilcoxon test between douglas and oak
wilcox.test(douglas_resil_2003, oak_resil_2003)





########----------------- **Environment Analysis**  ----------------#######

#1st requirement
#Already done and plotted in the prevous section, comment if needed



#2nd Requirement : Monthly climate requirement

clim<- read.csv2("climate_data_oehrberg.csv")
# head(clim)
# tail(clim)

# plot(clim$year,clim$temp,type="l")
# plot(ts(clim$temp,frequency = 12,start=1901),
#      ylab="Temperature(°C)",xlim=c( ))

#chronology or Robust Mean

spruce_chron <- chron(spruce_d)
douglas_chron <- chron(douglas_d)
oak_chron <- chron(oak_d)
#plot(spruce_chron)

"
response function
y=mx+C
Tree ring chronology = f(Climate data)+C

"

# make july climate data
clim_july <- clim[clim$month == 7, ]
clim_july$month <- NULL
head(clim_july)

##create dendro data frame

douglas_july <- data.frame(
  year = as.numeric(rownames(douglas_chron)), 
  rwi = douglas_chron$std
)
douglas_july<-merge(douglas_july,clim_july)
head(douglas_july)

par(las=1)
plot(douglas_july$temp,douglas_july$rwi)

lm(rwi~temp,data=douglas_july) #linear model
"
Coefficients:
(Intercept)         temp  
    1.15010     -0.00914  
    
Negative relatioinship => Inverse relation

"
summary(lm(rwi~temp,data=douglas_july)) #Adjusted R-squared:  -0.001922  X 
summary(lm(rwi~prec,data=douglas_july)) #Adjusted R-squared:  0.05108   5% variablitiy X 


## -------------------  Calibration  -------------------------------#

#Install treeclim lib 

library(treeclim)

# my_calib<- dcc(douglas_chron,clim)
# my_calib
# 
# plot(my_calib)
# 
# set.seed(42) #set the seed for constant value selection
# my_calib<-dcc(douglas_chron,clim,selection = 3:9)
# plot(my_calib)


# my_calib2<-dcc(douglas_chron,clim,
#                selection =.mean(-6:8) + .mean(6:8))
# plot(my_calib2)
# 
# my_calib3<-dcc(douglas_chron,clim,
#                selection =.mean(-6:8,"prec") + .mean(6:8,"prec")+.mean(7:9,"temp"))
# plot(my_calib3)


#dynamic perpective for climate reconstruction and check the tree growth with climate conditions

my_calib1<-dcc(douglas_chron,clim,
               selection =
                 .sum(4:6, "prec") +
                 .sum(7:9, "prec") +
                 .mean(4:6, "temp") +
                 .mean(7:9, "temp"),
               dynamic="moving",
               win_size=20,win_offset = 3) #offest changes the beginning and end of the year for each calculation and * denotes sigificant corelation
plot(my_calib1)

my_calib2<-dcc(spruce_chron,clim,
               selection =
                 .sum(4:6, "prec") +
                 .sum(7:9, "prec") +
                 .mean(4:6, "temp") +
                 .mean(7:9, "temp"),
               dynamic="moving",
               win_size=20,win_offset = 3) 
plot(my_calib2)

my_calib3<-dcc(oak_chron,clim,
               selection =
                 .sum(4:6, "prec") +
                 .sum(7:9, "prec") +
                 .mean(4:6, "temp") +
                 .mean(7:9, "temp"),
               dynamic="moving",
               win_size=20,win_offset = 3) 
plot(my_calib3)


#----------------  dlm - dendo linear model  ---------------------#


spruce_dlm <- dlm(spruce_chron, clim,
                  selection = .range(6:8, "prec"))
#spruce_dlm
summary(spruce_dlm) #Adjusted R-squared:  0.1727 explains 17% of variability is explained

douglas_dlm <- dlm(douglas_chron, clim,
              selection = .range(6:8, "prec"))
#douglas_dlm
summary(douglas_dlm)

oak_dlm <- dlm(oak_chron, clim,
                   selection = .range(6:8, "prec"))
#oak_dlm
summary(oak_dlm)




my_dlm2 <- dlm(douglas_chron, clim,
               selection = .sum(6:8, "prec"))  #for precipitation use sum so much not mean
summary(my_dlm2)   

"
Coefficients:
                                     Estimate Std. Error t value Pr(>|t|)    
(Intercept)                         0.7931132  0.0501141  15.826  < 2e-16 ***
prec.sum.curr.jun.curr.jul.curr.aug 0.0009029  0.0002182   4.137 8.46e-05 ***

Both are significant

"
douglas_skills <- skills(my_dlm2) #skills for single 
plot(douglas_skills) 

#g_test(my_calib4)

