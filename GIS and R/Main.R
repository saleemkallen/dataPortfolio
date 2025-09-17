###hands on 5: 

###comparing field vs. forest using drone data

###first we have to load a package (install first)

library(terra)

###specify our work directory for easier data access

setwd("D:/deeema/DEEEMA/GIS/LECTURE OTES/data")
getwd()  

list.files()

RAST<-rast(list.files(pattern="tif"))

RAST

###we now want to have a first glimpse

plot(RAST)

names(RAST)

plotRGB(RAST[[c(4,2,1)]],stretch=TRUE)###stretch is very important otherwise black plot

###okay so we are looking at a forest edge facing southward

###comparing field vs. forest using drone data

AOI_FOREST<-draw() #are of interest

AOI_FOREST

AOI_FIELD<-draw()

AOI_FOREST<-ext(c(647644.248264156, 647684.303296076, 5463144.04040026, 5463190.49767089))

lines(AOI_FOREST,col="blue",lwd=3)

AOI_FIELD<-ext(c(647657.381061507, 647677.572737434, 5463100.53800904, 5463119.5805652))

RAST_FOREST<-crop(RAST,AOI_FOREST)

plotRGB(RAST_FOREST[[c(4,2,1)]],stretch=TRUE)

RAST_FIELD<-crop(RAST,AOI_FIELD)

plotRGB(RAST_FIELD[[c(4,2,1)]],stretch=TRUE)

###so, we have now prepared our AOI-raster objects

###statistical comparison

###to get the data:

DF_FOREST<-as.data.frame(RAST_FOREST)
DF_FIELD<-as.data.frame(RAST_FIELD)

head(DF_FOREST)

boxplot(list(DF_FOREST[,1],DF_FIELD[,1]),
        names=c("forest","field"),main="blue reflectance")

wilcox.test(DF_FOREST[,1],DF_FIELD[,1])

###homework: make this comparison for the other bands as well

NDVI_FOREST<-(RAST_FOREST[[3]]-RAST_FOREST[[4]])/(RAST_FOREST[[3]]+RAST_FOREST[[4]])

NDVI_FIELD<-(RAST_FIELD[[3]]-RAST_FIELD[[4]])/(RAST_FIELD[[3]]+RAST_FIELD[[4]])

boxplot(values(NDVI_FOREST)[,1],values(NDVI_FIELD)[,1],
        names=c("forest","field"),main="NDVI")

plot(NDVI_FIELD)


###now for the whole image

NDVI<-(RAST[[3]]-RAST[[4]])/(RAST[[3]]+RAST[[4]])

names(NDVI)<-"NDVI"

plot(NDVI)

COL<-colorRampPalette(c("red","orange","grey","dodgerblue","blue"))

plot(rep(1,100),col=COL(100),pch=16,cex=2)

plot(NDVI,col=COL(100))

################################################################################

###session 2: 11th of December 2024

###homework 1: compare broadleaved vs. conifer trees

plotRGB(RAST[[c(4,2,1)]],stretch=T)

AOI_BL<-draw()

AOI_CN<-draw()

AOI_BL<-ext(c(647645.278615661, 647658.056848907, 5463181.66650739, 5463194.2829908))

lines(AOI_BL,col="orange",lwd=2)

DF_BL<-as.data.frame(crop(NDVI,AOI_BL))
DF_CN<-as.data.frame(crop(NDVI,AOI_CN))

boxplot(DF_BL[,1],DF_CN[,1],names=c("broadleaved","coniferous"),
        ylab="NDVI",cex.lab=1.5,cex.axis=1.5)

shapiro.test(DF_BL[,1])

wilcox.test(DF_BL[,1],DF_CN[,1])

###significant difference in NDVI 

###homework 2: compute EVI and NDRE and make the same comparisons as before

EVI<-2.5*(RAST[[3]]-RAST[[4]])/(RAST[[3]]+6*RAST[[4]]+7.5*RAST[[1]]+1)

names(EVI)<-"EVI"

NDRE<-(RAST[[3]]-RAST[[5]])/(RAST[[3]]+RAST[[5]])

names(NDRE)<-"NDRE"

DF_BL<-as.data.frame(crop(c(NDVI,EVI,NDRE),AOI_BL))
DF_CN<-as.data.frame(crop(c(NDVI,EVI,NDRE),AOI_CN))

boxplot(DF_BL[,2],DF_CN[,2],names=c("broadleaved","coniferous"),
        ylab="EVI",cex.lab=1.5,cex.axis=1.5)

boxplot(DF_BL[,3],DF_CN[,2],names=c("broadleaved","coniferous"),
        ylab="NDRE",cex.lab=1.5,cex.axis=1.5)

par(mfrow=c(1,3))

boxplot(DF_BL[,1],DF_CN[,1],names=c("broadleaved","coniferous"),
        ylab="NDVI",cex.lab=1.5,cex.axis=1.5)

boxplot(DF_BL[,2],DF_CN[,2],names=c("broadleaved","coniferous"),
        ylab="EVI",cex.lab=1.5,cex.axis=1.5)

boxplot(DF_BL[,3],DF_CN[,2],names=c("broadleaved","coniferous"),
        ylab="NDRE",cex.lab=1.5,cex.axis=1.5)


par(mfrow=c(1,2))

plot(EVI,col=COL(100),main="EVI",range=c(0,0.7))
plot(NDRE,col=COL(100),main="NDRE",range=c(0,0.7))

###apparently, NDRE is better suited to differentiate between conifers and broadleaves #NDVI for assignment
###note, that this might be specific to our data since conifers were stressed
###which is better mirrored in the NDRE












###hands on 8: compute NDVI for the whole scene of Maisenlach
###reproduce the forest-edge distance gradient evaluation of NDVI

#setwd("D://WORK//Teaching//WS24_25//HSWT_CCM//data//course_data//Data_course_2a")  

list.files()

###read in all bands

RAST<-rast(list.files(pattern="tif"))

###set the graphics device to original state:

par(mfrow=c(1,1))

dev.off()###if you want to completely reset to default state

###get a visual impression in RGB

plotRGB(RAST[[c(4,2,1)]],stretch=T)

###compute the NDVI

NDVI<-(RAST[[3]]-RAST[[4]])/(RAST[[3]]+RAST[[4]])

###name it

names(NDVI)<-"NDVI"

###redefine color scale

COL<-colorRampPalette(c("red","orange","yellow","dodgerblue","blue"))

###now visualize NDVI

plot(NDVI,col=COL(100))

###now read in the digitized Scots pine canopy shapes

#setwd("Pine_shape")

list.files()

SHAPE<-vect(list.files(pattern=".shp"))

lines(SHAPE)

###now we want to extract the corresponding NDVI for each canopy

###this calls for a loop

###we will first make a blueprint for the first canopy and then 
###iteratively repeat this

plot(SHAPE[1,])

lines(SHAPE[1,],lwd=3)

###there are some irregular polygon geometries which we have to remove

SHAPE<-SHAPE[c(1:20,22:30,50:55,58:68,70:112,114:133,
               135:404,406:475,477:609,611:708,
               712:1065,1067:1503)]

NDVI_PiSy<-mean(extract(NDVI,SHAPE[1,])[,2])

for(i in c(2:1471))
{
  NDVI_PiSy<-c(NDVI_PiSy,mean(extract(NDVI,SHAPE[i,])[,2]))
  print(i)
}

###now we have 1471 mean canopy NDVI values

NDVI_PiSy

###we have to extract the mean coordinate of each polygon

CRDS<-apply(crds(SHAPE[1,]),2,mean)

###again in a loop

for(i in 2:1471)
{
  CRDS<-rbind(CRDS,apply(crds(SHAPE[i,]),2,mean))
  print(i)
}


CRDS

plot(NDVI_PiSy~CRDS[,2],pch=16,ylab="NDVI",xlab="Northing")



###we can do this better

plotRGB(RAST[[c(4,2,1)]],stretch=T)

ForestEdge<-locator()

lines(ForestEdge,lwd=3)

CRDS_Edge<-cbind(ForestEdge$x,ForestEdge$y)
colnames(CRDS_Edge)<-c("Easting","Northing")

###in case you have problems with the graphics device

# CRDS_Edge<-cbind(c(647573.3, 647587.7, 647605.3, 647619.7, 647634.8,
#                    647654.8, 647672.4, 647693.1, 647715.1, 647735.1,
#                    647755.8, 647776.5, 647797.9, 647816.1, 647837.4,
#                    647856.2, 647875.7, 647894.5, 647908.9),
#                  c(5463191, 5463179, 5463167, 5463157, 5463143,
#                    5463135, 5463128, 5463127, 5463131, 5463135,
#                    5463139, 5463142, 5463137, 5463133, 5463130, 
#                    5463124, 5463120, 5463118, 5463115))


###blueprint computing the minimum forest-edge distance for the first canopy

DIST_CANOPY_EDGE<-dist(rbind(CRDS[1,],CRDS_Edge[1,]))

for(i in 2:19)
{
  DIST_CANOPY_EDGE<-c(DIST_CANOPY_EDGE,
                      dist(rbind(CRDS[1,],CRDS_Edge[i,])))
  print(i)
}

FOREST_EDGE_DISTANCE<-min(DIST_CANOPY_EDGE)

###now in a nested loop:

for(j in 2:1471)
{
  DIST_CANOPY_EDGE<-dist(rbind(CRDS[j,],CRDS_Edge[1,]))
  
  for(i in 2:19)
  {
    DIST_CANOPY_EDGE<-c(DIST_CANOPY_EDGE,
                        dist(rbind(CRDS[j,],CRDS_Edge[i,])))
    #print(i)
  }
  
  FOREST_EDGE_DISTANCE<-c(FOREST_EDGE_DISTANCE,min(DIST_CANOPY_EDGE))
  print(j)
}

plot(NDVI_PiSy~FOREST_EDGE_DISTANCE,xlab="forest edge distance [m]",
     ylab="NDVI",pch=16)


###########################################################################


















###session 3: 18.12.2024

###hands on: working with the MODIS data

library(terra)

setwd("D:\\deeema\\DEEEMA\\GIS\\ASSIGNMENT\\RS Fr") 

###get an overview on existing files

list.files(pattern=".shp")
list.files(pattern=".tif")

###load the shape of the Harz mountains

SHAPE<-vect(list.files(pattern=".shp"))

plot(SHAPE)

###load the ndvi rasters

NDVI.HARZ<-rast(list.files(pattern="NDVI"))

NDVI.HARZ

###get a visual impression

plot(NDVI.HARZ[[1]])

lines(SHAPE)###this did not work, due to a different crs - coordinate reference system

###we have to reproject our shapefile

SHAPE.P<-project(SHAPE,crs(NDVI.HARZ))

lines(SHAPE.P,lwd=3)

###load the pixel reliability information

PR.HARZ<-rast(list.files(pattern="pixel"))

PR.HARZ

plot(PR.HARZ[[1]],legend=TRUE)

lines(SHAPE.P,lwd=3)

###crop and mask NDVI and PR

NDVI.HARZ.M<-mask(NDVI.HARZ,SHAPE.P) 

plot(NDVI.HARZ.M[[1]])

NDVI.HARZ.M.C<-crop(NDVI.HARZ.M,SHAPE.P)

plot(NDVI.HARZ.M.C[[1]])

###and the same for PR, can be done in one nested code

PR.HARZ.M.C<-crop(mask(PR.HARZ,SHAPE.P),SHAPE.P)

plot(PR.HARZ.M.C[[16]])


###next step: use pixel reliability layer to mask NDVI

###blueprint for the first NDVI layer

NDVI.HARZ.M.C[[1]][PR.HARZ.M.C[[1]]>1]<-NA

plot(NDVI.HARZ.M.C[[1]])###masking was successful

###we can do this in a loop

for(i in 1:nlyr(NDVI.HARZ.M.C))
{
  NDVI.HARZ.M.C[[i]][PR.HARZ.M.C[[i]]>1]<-NA
}

plot(NDVI.HARZ.M.C[[23]])  


#pixels are of good quality

#time series

###evaluate the temporal dynamics of NDVI over two years
###and compare the two years with each other

###look at peak season NDVI (july or august) 

DATES<-as.POSIXct(substr(names(NDVI.HARZ.M.C),35,41),format="%Y%j") #trial and error to find where the time data in the name is
names(NDVI.HARZ.M.C)
DATES

NDVI.HARZ.2017<-app(NDVI.HARZ.M.C[[48:58]],"mean",na.rm=T) #july till november

NDVI.HARZ.2018<-app(NDVI.HARZ.M.C[[26:36]],"mean",na.rm=T)

###now look at this

COL<-colorRampPalette(c("red","orange","grey","dodgerblue","blue"))

plot(c(NDVI.HARZ.2018,NDVI.HARZ.2017),col=COL(100),
     main=c(2018,2017))

plot(NDVI.HARZ.2018-NDVI.HARZ.2017,col=COL(100),
     range=c(-0.2,0.2))   #NDVI lower in 2018 (-ve value)

DF.NDVI.HARZ<-as.data.frame(c(NDVI.HARZ.2017,NDVI.HARZ.2018))

names(DF.NDVI.HARZ)<-c(2017,2018)

head(DF.NDVI.HARZ)

boxplot(DF.NDVI.HARZ)

wilcox.test(DF.NDVI.HARZ[,1],DF.NDVI.HARZ[,2],paired=T)

boxplot(DF.NDVI.HARZ[,2]-DF.NDVI.HARZ[,1])
abline(0,0)  # below zero line says that the NDVI of 2017 was higher than 2018 due to drought event in 2018








###let's look at a more time-dynamic evaluation  

MEAN.NDVI.HARZ<-global(NDVI.HARZ.M.C,"mean",na.rm=T)

plot(MEAN.NDVI.HARZ[,1]~DATES,type="l",lwd=3,
     ylab="NDVI",xlab="time")

###compare the two seasons with each other

length(MEAN.NDVI.HARZ[1:35, 1])
length(seq(1, 365, 16))


plot(MEAN.NDVI.HARZ[1:23,1]~seq(1,365,16),type="l",lwd=3,
     ylab="NDVI",xlab="DOY",col="dodgerblue",
     cex.lab=1.5,cex.axis=1.5,main="Harz",cex.main=1.5)  #23 is the half of the layerrs 

lines(MEAN.NDVI.HARZ[24:46,1]~seq(1,365,16),col="orange",lwd=3)
legend(x=0,y=.8,legend=c("2017","2018"),fill=c("dodgerblue","orange"),
       cex=1.5)

wilcox.test(MEAN.NDVI.HARZ[1:23,1],MEAN.NDVI.HARZ[24:46,1],
            paired=T) # paired by time

wilcox.test(MEAN.NDVI.HARZ[11:18,1],MEAN.NDVI.HARZ[23+11:18,1],
            paired=T)

###exercise: redo all the steps above for EVI








###working with the forest condition monitor:
library(terra)

COL<-colorRampPalette(c("red","orange","grey","dodgerblue","blue"))

setwd("D:\\deeema\\DEEEMA\\GIS\\ASSIGNMENT\\forest_condition_monitor") 
RAST.WZM<-rast(list.files(pattern="tif"))

RAST.WZM

###get a visual impression

plot(RAST.WZM,col=COL(22),main=c("2019","2020","2021","2022"))


#2022 and 2019 were worst around freising in comparison to other years

par(mfrow = c(1, 2))  # 1 row, 2 columns

# First plot: Difference map for 2019 and 2020
plot(RAST.WZM[[2]] - RAST.WZM[[1]], col = COL(22), #2020 was good compared to 2019
     main = "Difference: 2020 - 2019")

# Second plot: Difference map for 2022 and 2021
plot(RAST.WZM[[4]] - RAST.WZM[[3]], col = COL(22),
     main = "Difference: 2022 - 2021")
#in 2022 (red) condition was worse, the canopy green was lower in comparison to 2021

#plot(RAST.WZM[[2]]-RAST.WZM[[1]],col=COL(22)) #difference map
#plot(RAST.WZM[[3]]-RAST.WZM[[4]],col=COL(22)) #difference map


# Load required package
library(ggplot2)
library(reshape2)

# Convert data from wide to long format
DF_long <- melt(DF.WZM, variable.name = "Year", value.name = "WZM_Quantile")

# Define custom colors
custom_colors <- c("2019" = "#D73027",  # Dark Red
                   "2020" = "#4575B4",  # Dark Blue
                   "2021" = "#91BFDB",  # Light Blue
                   "2022" = "#FC8D59")  # Light Red

# Create the boxplot
ggplot(DF_long, aes(x = Year, y = WZM_Quantile, fill = Year)) +
  geom_boxplot(alpha = 0.8, outlier.color = "black", outlier.shape = 16) +
  scale_fill_manual(values = custom_colors) + 
  labs(y = "WZM Quantile", x = "Year", title = "WZM Quantile Distribution (2019-2022)") +
  theme_minimal(base_size = 16) +
  theme(legend.position = "none",
        axis.text.x = element_text(angle = 45, hjust = 1))

# 
# 
# par(mfrow = c(1, 1))
# 
# DF.WZM<-as.data.frame(RAST.WZM)
#  
# names(DF.WZM)<-c("2019","2020","2021","2022")
# 
# head(DF.WZM)
# 
# boxplot(DF.WZM,ylab="WZM Quantile",
#         cex.lab=1.5,cex.axis=1.5)
#2019 and 2022 has a systematically low NDVI or quanntile basically

wilcox.test(DF.WZM[,1],DF.WZM[,2],paired=T)
wilcox.test(DF.WZM[,3],DF.WZM[,4],paired=T)

# p-value < 2.2e-16 -> systematically low NDVI in 22 and 19 compared to 20 and 21

par(mfrow = c(1, 2))

boxplot(DF.WZM[,1]-DF.WZM[,2],ylab="WZM Quantile",
        cex.lab=1.5,cex.axis=1.5)
abline(0,0)

boxplot(DF.WZM[,3]-DF.WZM[,4],ylab="WZM Quantile",
        cex.lab=1.5,cex.axis=1.5)
abline(0,0)

#summary of difference

summary(DF.WZM[,1]-DF.WZM[,2])
summary(DF.WZM[,3]-DF.WZM[,4])

#look for specficic forest disturbances happened
#2019 affecte by the drought of 2018 and 2022


###how can we draw a histogram?

HIST.2019<-hist(DF.WZM[,1],breaks=seq(0.5,22.5,1))
HIST.2020<-hist(DF.WZM[,2],breaks=seq(0.5,22.5,1))

HIST.2021<-hist(DF.WZM[,3],breaks=seq(0.5,22.5,1))
HIST.2022<-hist(DF.WZM[,4],breaks=seq(0.5,22.5,1))


HIST.MAT.1<-rbind(HIST.2019$counts,HIST.2020$counts)
HIST.MAT.2<-rbind(HIST.2021$counts,HIST.2022$counts)

rownames(HIST.MAT.1)<-c(2019,2020)
colnames(HIST.MAT.1)<-paste(1:22)

rownames(HIST.MAT.2)<-c(2021,2022)
colnames(HIST.MAT.2)<-paste(1:22)


HIST.MAT.1
HIST.MAT.2


par(mfrow = c(2, 1))

barplot(HIST.MAT.1,beside=T,
        ylab="counts",xlab="NDVI rank",
        col=rep(COL(22),each=2),
        main = "2019 vs 2020")


barplot(HIST.MAT.2,beside=T,
        ylab="counts",xlab="NDVI rank",
        col=rep(COL(22),each=2),
        main = "2021 vs 2022")
#left and right

########################################################



#2024 vs 2018/17
"
Compare two different years (e.g. 2018 vs. 2024) regarding their
temporal NDVI curve for the forest patch that you‘ve downloaded using
MODIS. Make an appealing graph and interpret the visualization of the
time-series.

right data
draw shape file AIO
Interpretation of time series
describe in own words
how NDVI compare and what does means( land cover , foirest type, stress and disturbance)


2. Select a municipal district in Germany and download quantiles from the
German forest condition monitor (deutschland.waldzustandsmonitor.de)
for end of July in 2017, 2018, 2019, and 2020. Compare the four timesteps statistically with each other and draw appealing maps to display
the differences.

Histograms
wilcox test

1 is sufficient
content
why specifically selected a date
question beind - drough or late frost event etc
why specific example
wilcox test - write someting if doing
(watch last lecture again in the end)
 
""










