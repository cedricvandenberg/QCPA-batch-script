# Extracting variables

# set Working directory



# loading packages

library(dplyr); library(data.table)

# Code for extracting parameters from Batch QCPA output

pth<-getwd() #assumes the script is placed in the same folder as the data
 
Extrct_Fold="Test Data" #set folder name containing your data

Species=list.files(path=paste0(pth,"/",Extrct_Fold)) #detects what species are in the dataset. These could also be locations depending on your dataset. 

Species = Species[-length(Species)] #remove the log file

Collated_Info<-data.frame(NULL)
for (spc in 1:length(Species)) {
  Ind_pth<-paste0(pth,"/",Extrct_Fold, "/",Species[spc])
  Indviduals_list<-list.files(path=Ind_pth)
  for (i in 1:length(Indviduals_list)){
    Dists<-list.files(paste0(Ind_pth,"/", Indviduals_list[i]),pattern = "cm")
    for (j in 1: length(Dists)){
      ani_info<-fread(paste0(Ind_pth,"/",Indviduals_list[i], "/",Dists[j],
                             "/Animal_Summary Results.csv"))[,V1:=NULL][, `:=`(ROI="animal", DIST=Dists[j], Species=Species[spc], Individual=Indviduals_list[i])]
      
      bakg_info<-fread(paste0(Ind_pth,"/",Indviduals_list[i], "/",Dists[j],
                              "/Background_Summary Results.csv"))[,V1:=NULL][, `:=`(ROI="background", DIST=Dists[j], Species=Species[spc],Individual=Indviduals_list[i])]
      
      ani_bakg_info<-fread(paste0(Ind_pth,"/",Indviduals_list[i], "/",Dists[j],
                              "/animal+background_Summary Results.csv"))[,V1:=NULL][, `:=`(ROI="animal + background", DIST=Dists[j], Species=Species[spc],Individual=Indviduals_list[i])]
      
      
      ani_LEIA<-fread(paste0(Ind_pth,"/",Indviduals_list[i], "/",Dists[j], "/LEIA/animal/_Local Edge Intensity Analysis.csv")
      )[,V1:=NULL]
      
      bakg_LEIA<-fread(paste0(Ind_pth,"/",Indviduals_list[i], "/",Dists[j], "/LEIA/background/_Local Edge Intensity Analysis.csv")
      )[,V1:=NULL]
      
      ani_bakg_LEIA<-fread(paste0(Ind_pth,"/",Indviduals_list[i], "/",Dists[j], "/LEIA/animal+background/_Local Edge Intensity Analysis.csv")
      )[,V1:=NULL]
      
      
      ani_Gabrat<-fread(paste0(Ind_pth,"/",Indviduals_list[i], "/",Dists[j], "/Gabrat/_GabRat_Results.csv") #extracting the relevant GabRat value --> 4th line in the csv file is the dbl resuit. Change if interested in a different channel
      )[,V1:=NULL][4,]
      
      bakg_Gabrat<-fread(paste0(Ind_pth,"/",Indviduals_list[i], "/",Dists[j], "/Gabrat/_GabRat_Results.csv") #note that usually only the GabRat value of the 'Animal' ROI is of interest as GabRat operates at the edge of an ROI. 
      )[,V1:=NULL][12,]
      
      ani_bakg_Gabrat<-fread(paste0(Ind_pth,"/",Indviduals_list[i], "/",Dists[j], "/Gabrat/_GabRat_Results.csv")
      )[,V1:=NULL][8,]
      
      
      
      cbind(ani_LEIA, ani_Gabrat, ani_info)-> ani_sum
      cbind(bakg_LEIA, bakg_Gabrat, bakg_info)-> bakg_sum
      cbind(ani_bakg_LEIA, ani_bakg_Gabrat, ani_bakg_info)-> ani_bakg_sum
      
      rbind(ani_sum,bakg_sum,ani_bakg_sum, Collated_Info) -> Collated_Info
    }
  }
}


write.csv(Collated_Info, "Summary_all.csv", row.names = FALSE)


