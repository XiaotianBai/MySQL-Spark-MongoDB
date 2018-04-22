df <- read.csv(file="/home/data/MT/dataset3/d09.csv",sep=",",header=F,stringsAsFactors=F)
d_featrues <- df[,c(3:12,15,17,18,19,20,21,22,38,43,44,45,46,47)]
colnames(d_featrues) <- c("V1", "V2","V3","V4","V5", "V6", "V7", "State","State_Abbr","V10","Dwelling","Occupancy", "V13","Loan_Type","Loan_Purpose","Lien_Type","HOEPA","Gender","Race", "SpaOrLat", "Administration", "Admin_Abbr", "Loan_Status")
write.csv(d_featrues, file = "/home/2018/spring/nyu/6513/xb306/T1/d3/features.csv",row.names=FALSE)