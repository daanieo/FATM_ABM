


library(ggplot2)


ggplot(total_df) + geom_line(aes(x=as.numeric(tick),y=as.numeric(DemandedFood),color=as.numeric(beta)))
+geom_line(aes(x=as.numeric(tick),y=as.numeric(EmotionalState),color=as.numeric(beta)))




### Compare 
ratio <- 10
ggplot(total_df)+ 
  geom_line(aes(x=as.numeric(tick),y=as.numeric(DemandedFood),color="red"))+
  geom_line(aes(x=as.numeric(tick),y=as.numeric(EmotionalState)*ratio,color="blue"))+
  
  # Custom the Y scales:
  scale_y_continuous(
    
    # Features of the first axis
    name = "Amount of food demanded",
    
    # Add a second axis and specify its features
    sec.axis = sec_axis( trans=~.*(1/ratio), name="Emotional State")
  ) 
