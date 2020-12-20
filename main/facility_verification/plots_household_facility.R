
library(ggplot2)

# import results

total_df <- read.csv("/home/daan/Desktop/Verification_results/HouseholdsToFacility.csv")

runtime <- 30*24*6 # days times hours times tick per hour 
samplesize <- nrow(total_df)/runtime

# theme
theme <- theme(plot.title = element_text(family = "Helvetica", size = (17.5)),
                      legend.text = element_text(face = "italic", colour="black",family = "Helvetica"), 
                      axis.title = element_text(family = "Helvetica", size = (17.5), colour = "black"),
                      axis.text=element_text())

# length of queue, variation w capacity, day 1-30
p <- ggplot()+xlim(0,2200) +theme+ ggtitle("Length of queue over time (day 1-15), gamma 1-30, PllServed 1-10") + labs(x="ticks [10 min]",y="Length of queue [# people]",colour="PllServed",size=(200))+scale_colour_gradient(low="lightgreen",high="green4")

for (s in 0:(samplesize-1)) {
  until<-as.numeric(until)
  p<-p+geom_line(aes_string(x=as.numeric(total_df$tick[(s*until+1):((s+1)*until+1)]),y=as.numeric(total_df$QueueLength[(s*until+1):((s+1)*until+1)]),color=as.numeric(total_df$ParallelServed[(s*until+1):((s+1)*until+1)]))) #
}
print(p)

# length of queue e, variation with gamma, day 1-15
p <- ggplot() +xlim(0,2200)+theme+ ggtitle("Length of queue over time (day 1-15), gamma 1-30, PllServed 1-10") + labs(x="ticks [10 min]",y="Length of queue [# people]",colour="gamma",size=(200))+scale_colour_gradient(low="lightblue",high="blue4")
for (s in 0:(samplesize-1)) {
  until<-as.numeric(until)
  p<-p+geom_line(aes_string(x=as.numeric(total_df$tick[(s*until+1):((s+1)*until+1)]),y=as.numeric(total_df$QueueLength[(s*until+1):((s+1)*until+1)]),color=as.numeric(total_df$gamma[(s*until+1):((s+1)*until+1)]))) #
}
print(p)

# food in storage, variation with gamma, day 1
p <- ggplot() +xlim(0,150)+theme+ ggtitle("Length of queue over time (day 1), gamma 1-30, PllServed 1-10") + labs(x="ticks [10 min]",y="Length of queue [# people]",colour="gamma",size=(200))+scale_colour_gradient(low="lightblue",high="blue4")
for (s in 0:(nrow(params_sample)-1)) {
  until<-as.numeric(until)
  p<-p+geom_line(aes_string(x=as.numeric(total_df$tick[(s*until+1):((s+1)*until+1)]),y=as.numeric(total_df$QueueLength[(s*until+1):((s+1)*until+1)]),color=as.numeric(total_df$gamma[(s*until+1):((s+1)*until+1)]))) #
}
print(p)

# food in storage, variation with gamma, day 15
p <- ggplot() +xlim(2000,2200)+theme+ ggtitle("Length of queue over time (day 15), gamma 1-30, PllServed 1-10") + labs(x="ticks [10 min]",y="Length of queue [# people]",colour="gamma",size=(200))+scale_colour_gradient(low="lightblue",high="blue4")
for (s in 0:(nrow(params_sample)-1)) {
  until<-as.numeric(until)
  p<-p+geom_line(aes_string(x=as.numeric(total_df$tick[(s*until+1):((s+1)*until+1)]),y=as.numeric(total_df$QueueLength[(s*until+1):((s+1)*until+1)]),color=as.numeric(total_df$gamma[(s*until+1):((s+1)*until+1)]))) #
}
print(p)

# Size of food delivery, variation with gamma
p <- ggplot() +xlim(0,2200)+theme+ ggtitle("Average withdrawal size over time (day 1-15), gamma 1-30, PllServed 1-10") + labs(x="ticks [10 min]",y="Average per withdrawal [kg]",colour="gamma",size=(200))+scale_colour_gradient(low="lightblue",high="blue4")
for (s in 0:(nrow(params_sample)-1)) {
  until<-as.numeric(until)
  p<-p+geom_line(aes_string(x=as.numeric(total_df$tick[(s*until+1):((s+1)*until+1)]),y=as.numeric(total_df$AverageDeliverySize[(s*until+1):((s+1)*until+1)]),color=as.numeric(total_df$gamma[(s*until+1):((s+1)*until+1)]))) #
}
print(p)



##############################

# import results



# Filter for high and low gamma values 
filtered_df<-na.omit( total_df  %>% filter(gamma==5 ) )

# 2 gammas and 10 for capacity
samplesize<-2*10

p <- ggplot() +xlim(0,2200)+theme+ ggtitle("Length of queue over time (day 1-15), gamma = 5") + labs(x="ticks [10 min]",y="Length of queue [# people]",colour="PllServed",size=(200))+scale_colour_gradient(low="lightgreen",high="green4")
for (s in 0:(samplesize-1)) {
  until<-as.numeric(until)
  p<-p+geom_line(aes_string(x=as.numeric(filtered_df$tick[(s*until+1):((s+1)*until+1)]),y=as.numeric(filtered_df$QueueLength[(s*until+1):((s+1)*until+1)]),color=as.numeric(filtered_df$ParallelServed[(s*until+1):((s+1)*until+1)]))) #
}
print(p)

# Filter for high and low gamma values 
filtered_df<-na.omit( total_df  %>% filter( gamma==20) )

# 2 gammas and 10 for capacity
samplesize<-2*10

p <- ggplot() +xlim(0,2200)+theme+ ggtitle("Length of queue over time (day 1-15), gamma = 20") + labs(x="ticks [10 min]",y="Length of queue [# people]",colour="PllServed",size=(200))+scale_colour_gradient(low="lightgreen",high="green4")
for (s in 0:(samplesize-1)) {
  until<-as.numeric(until)
  p<-p+geom_line(aes_string(x=as.numeric(filtered_df$tick[(s*until+1):((s+1)*until+1)]),y=as.numeric(filtered_df$QueueLength[(s*until+1):((s+1)*until+1)]),color=as.numeric(filtered_df$ParallelServed[(s*until+1):((s+1)*until+1)]))) #
}
print(p)





