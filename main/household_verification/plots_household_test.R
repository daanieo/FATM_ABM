


library(ggplot2)

# import results

total_df <- read.csv("results/RStartle.csv")
until<-4320


# theme
theme <- theme(plot.title = element_text(family = "Helvetica", size = (17.5)),
                      legend.text = element_text(face = "italic", colour="black",family = "Helvetica"), 
                      axis.title = element_text(family = "Helvetica", size = (17.5), colour = "black"),
                      axis.text=element_text())

# emotional state, variation with alpha
p <- ggplot()+xlim(0,2000) +theme+ ggtitle("Emotional state over time, one household, 'startle'") + labs(x="ticks",y="emotional state",colour="alpha",size=(200))
for (s in 0:(nrow(params_sample)-1)) {
  until<-as.numeric(until)
  p<-p+geom_line(aes_string(x=as.numeric(total_df$tick[(s*until+1):((s+1)*until+1)]),y=as.numeric(total_df$EmotionalState[(s*until+1):((s+1)*until+1)]),color=as.numeric(total_df$alpha[(s*until+1):((s+1)*until+1)]))) #
}
print(p)

# food in storage, variation with alpha
p <- ggplot() +theme+ ggtitle("Food in storage over time, one household, 'startle'") + labs(x="ticks",y="Food in storage",colour="alpha",size=(200))
for (s in 0:(nrow(params_sample)-1)) {
  until<-as.numeric(until)
  p<-p+geom_line(aes_string(x=as.numeric(total_df$tick[(s*until+1):((s+1)*until+1)]),y=as.numeric(total_df$FoodInStorage[(s*until+1):((s+1)*until+1)]),color=as.numeric(total_df$alpha[(s*until+1):((s+1)*until+1)]))) #
}
print(p)

# food in storage, variation with gamma
p <- ggplot()  + theme+ ggtitle("Food in storage over time, one household, 'startle'") + labs(x="ticks",y="Food in storage",colour="gamma",size=(200))
for (s in 0:(nrow(params_sample)-1)) {
  until<-as.numeric(until)
  p<-p+geom_line(aes_string(x=as.numeric(total_df$tick[(s*until+1):((s+1)*until+1)]),y=as.numeric(total_df$FoodInStorage[(s*until+1):((s+1)*until+1)]),color=as.numeric(total_df$gamma[(s*until+1):((s+1)*until+1)]))) #
}
print(p)

# food in storage, focus on gamma=5
p <- ggplot() +  geom_hline(yintercept=15/30*5*5*2,color="red")+geom_hline(yintercept=15/30*5*5,color="red") + theme+ ggtitle("Food in storage over time, one household, gamma=5, 'startle'") + labs(x="ticks",y="Food in storage",colour="alpha",size=(200))
for (s in 0:10) {
  until<-as.numeric(until)
  p<-p+geom_line(aes_string(x=as.numeric(total_df$tick[(s*until+1):((s+1)*until+1)]),y=as.numeric(total_df$FoodInStorage[(s*until+1):((s+1)*until+1)]),color=as.numeric(total_df$alpha[(s*until+1):((s+1)*until+1)]))) #
}
print(p)


############### without startle 

total_df <- read.csv("results/RNoStartle.csv")
# emotional state, variation with alpha
# food in storage, variation with gamma
p <- ggplot()  + theme+ ggtitle("Food in storage over time, one household, 'No startle'") + labs(x="ticks",y="Food in storage",colour="gamma",size=(200))
for (s in 0:(nrow(params_sample)-1)) {
  until<-as.numeric(until)
  p<-p+geom_line(aes_string(x=as.numeric(total_df$tick[(s*until+1):((s+1)*until+1)]),y=as.numeric(total_df$FoodInStorage[(s*until+1):((s+1)*until+1)]),color=as.numeric(total_df$gamma[(s*until+1):((s+1)*until+1)]))) #
}
print(p)



### Compare 
ratio <- 10
ggplot(total_df)+ 
  geom_line(aes(x=as.numeric(tick),y=as.numeric(FoodInStorage),color="red"))+
  geom_line(aes(x=as.numeric(tick),y=as.numeric(EmotionalState)*ratio,color="blue"))+
  
  # Custom the Y scales:
  scale_y_continuous(
    
    # Features of the first axis
    name = "Amount of food demanded",
    
    # Add a second axis and specify its features
    sec.axis = sec_axis( trans=~.*(1/ratio), name="Emotional State")
  ) 
