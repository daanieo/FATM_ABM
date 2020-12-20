# graphs
library(ggplot2)
# data filtering
library(dplyr)



# theme
theme <- theme(plot.title = element_text(family = "Helvetica", size = (17.5)),
                      legend.text = element_text(face = "italic", colour="black",family = "Helvetica"), 
                      axis.title = element_text(family = "Helvetica", size = (17.5), colour = "black"),
                      axis.text=element_text())

# 15 replications for beta=0.2 and beta=1 and alpha=0.1 and alpha=0.5; TWO REMARKABLE OUTLIERS
total_df <- read.csv("/home/daan/Desktop/Verification_results/Network_sampling_full.csv")

runtime <- 30*24*6
samplesize<-nrow(total_df)/runtime

# emotional state, variation with alpha, multiple replications
p <- ggplot()+xlim(0,4000) +theme+ ggtitle("Average Emotional State, full network, alpha = [0.1, 0.5], beta = [0.2, 1.0]") + labs(x="ticks [10 min]",y="Average emotional state [-]",colour="alpha",size=(200))+scale_colour_gradient(low="lightgreen",high="green4")
for (s in 0:(samplesize-1)) {
  until<-as.numeric(until)
  p<-p+geom_line(aes_string(x=as.numeric(total_df$tick[(s*until+1):((s+1)*until+1)]),y=as.numeric(total_df$AverageEmotionalState[(s*until+1):((s+1)*until+1)]),color=total_df$alpha[(s*until+1):((s+1)*until+1)])) #
}
print(p)

# emotional state, variation with beta, multiple replications
p <- ggplot()+xlim(0,4000) +theme+ ggtitle("Average Emotional State, full network, alpha = [0.1, 0.5], beta = [0.2, 1.0]") + labs(x="ticks [10 min]",y="Average emotional state [-]",colour="beta",size=(200))+scale_colour_gradient(low="lightblue",high="blue4")
for (s in 0:(samplesize-1)) {
  until<-as.numeric(until)
  p<-p+geom_line(aes_string(x=as.numeric(total_df$tick[(s*until+1):((s+1)*until+1)]),y=as.numeric(total_df$AverageEmotionalState[(s*until+1):((s+1)*until+1)]),color=total_df$beta[(s*until+1):((s+1)*until+1)])) #
}
print(p)



# Make the boxplots
bplot <- ggplot()+theme + ggtitle("Avg ES, full network, alpha=0.1, beta=[0.2,1.0]") + labs(x="ticks [10 min]",y="Average emotional state [-]",fill="beta")

for (s in 0:20) {
  df_tmp <- filter(total_df,tick==200*s,beta==1,alpha==0.1)
  bplot<-bplot + geom_boxplot(aes_string(x = 100*s-17.5,  y = df_tmp$AverageEmotionalState,fill=factor(df_tmp$beta)),width=30)
}

for (s in 0:20) {
  df_tmp <- filter(total_df,tick==200*s,beta==0.2,alpha==0.1)
  bplot <- bplot +  geom_boxplot(aes_string(x = s*100+17.5,  y = df_tmp$AverageEmotionalState,fill=factor(df_tmp$beta)),width = 30)
}
print(bplot)


# Another one

bplot <- ggplot()+ylim(0,0.1) + theme + ggtitle("Zoom: Avg ES, full network, alpha=0.1, beta=[0.2,1.0]") + labs(x="ticks [10 min]",y="Average emotional state [-]",fill="beta")

for (s in 0:20) {
  df_tmp <- filter(total_df,tick==200*s,beta==1,alpha==0.1)
  bplot<-bplot + geom_boxplot(aes_string(x = 100*s-17.5,  y = df_tmp$AverageEmotionalState,fill=factor(df_tmp$beta)),width=30)
}

for (s in 0:20) {
  df_tmp <- filter(total_df,tick==200*s,beta==0.2,alpha==0.1)
  bplot <- bplot +  geom_boxplot(aes_string(x = s*100+17.5,  y = df_tmp$AverageEmotionalState,fill=factor(df_tmp$beta)),width = 30)
}
print(bplot)


############# FOR THE SPARSE NETWORK

total_df <- read.csv("/home/daan/Desktop/Verification_results/Network_sampling_sparse.csv")


runtime <- 30*24*6
samplesize<-nrow(total_df)/runtime


# emotional state, variation with alpha, multiple replications
p <- ggplot()+xlim(0,4000) +theme+ ggtitle("Average Emotional State, sparse network, alpha = [0.1, 0.5], beta = [0.2, 1.0]") + labs(x="ticks [10 min]",y="Average emotional state [-]",colour="alpha",size=(200))+scale_colour_gradient(low="lightgreen",high="green4")
for (s in 0:(samplesize-1)) {
  until<-as.numeric(until)
  p<-p+geom_line(aes_string(x=as.numeric(total_df$tick[(s*until+1):((s+1)*until+1)]),y=as.numeric(total_df$AverageEmotionalState[(s*until+1):((s+1)*until+1)]),color=total_df$alpha[(s*until+1):((s+1)*until+1)])) #
}
print(p)

# emotional state, variation with beta, multiple replications
p <- ggplot()+xlim(0,4000) +theme+ ggtitle("Average Emotional State, sparse network, alpha = [0.1, 0.5], beta = [0.2, 1.0]") + labs(x="ticks [10 min]",y="Average emotional state [-]",colour="beta",size=(200))+scale_colour_gradient(low="lightblue",high="blue4")
for (s in 0:(samplesize-1)) {
  until<-as.numeric(until)
  p<-p+geom_line(aes_string(x=as.numeric(total_df$tick[(s*until+1):((s+1)*until+1)]),y=as.numeric(total_df$AverageEmotionalState[(s*until+1):((s+1)*until+1)]),color=total_df$beta[(s*until+1):((s+1)*until+1)])) #
}
print(p)


# Boxplots
bplot <- ggplot() + theme + ggtitle("Avg ES, sparse network, alpha=0.1, beta=[0.2,1.0]") + labs(x="ticks [10 min]",y="Average emotional state [-]",fill="beta")
for (s in 0:20) {
  df_tmp <- filter(total_df,tick==200*s,beta==1,alpha==0.1)
  bplot<-bplot + geom_boxplot(aes_string(x = 100*s-25,  y = df_tmp$AverageEmotionalState,fill=factor(df_tmp$beta)),width=40)
}

for (s in 0:20) {
  df_tmp <- filter(total_df,tick==200*s,beta==0.2,alpha==0.1)
  bplot <- bplot +  geom_boxplot(aes_string(x = s*100+25,  y = df_tmp$AverageEmotionalState,fill=factor(df_tmp$beta)),width = 40)
}
print(bplot)


# Another one

bplot <- ggplot()+ylim(0,0.05) + theme + ggtitle("Zoom: Avg ES, sparse network, alpha=0.1, beta=[0.2,1.0]") + labs(x="ticks [10 min]",y="Average emotional state [-]",fill="beta")
for (s in 0:20) {
  df_tmp <- filter(total_df,tick==200*s,beta==1,alpha==0.1)
  bplot<-bplot + geom_boxplot(aes_string(x = 100*s-25,  y = df_tmp$AverageEmotionalState,fill=factor(df_tmp$beta)),width=40)
}

for (s in 0:20) {
  df_tmp <- filter(total_df,tick==200*s,beta==0.2,alpha==0.1)
  bplot <- bplot +  geom_boxplot(aes_string(x = s*100+25,  y = df_tmp$AverageEmotionalState,fill=factor(df_tmp$beta)),width = 40)
}
print(bplot)

######## EXTREME VALUES 
total_df <- read.csv("/home/daan/Desktop/Verification_results/Network_sampling_full_EV.csv")

runtime <- 30*24*6
samplesize<-nrow(total_df)/runtime

# emotional state, variation with beta, multiple replications
p <- ggplot()+xlim(0,4000) +theme+ ggtitle("Average Emotional State, full network, alpha = [0.0], beta = [0.2, 1.0]") + labs(x="ticks",y="emotional state",colour="beta",size=(200))+scale_colour_gradient(low="lightblue",high="green4")
for (s in 0:(nrow(params_sample)*replications-1)) {
  until<-as.numeric(until)
  p<-p+geom_line(aes_string(x=as.numeric(total_df$tick[(s*until+1):((s+1)*until+1)]),y=as.numeric(total_df$AverageEmotionalState[(s*until+1):((s+1)*until+1)]),color=total_df$beta[(s*until+1):((s+1)*until+1)])) #
}
print(p)

# Boxplots
bplot <- ggplot()+ theme + ggtitle(" Avg ES, full network, alpha=0.0, beta=[0.2,1.0]") + labs(x="ticks [10 min]",y="Average emotional state [-]",fill="beta")
for (s in 0:20) {
  df_tmp <- filter(total_df,tick==200*s,beta>=0.5)
  bplot<-bplot + geom_boxplot(aes_string(x = 100*s-25,  y = df_tmp$AverageEmotionalState,fill=factor(df_tmp$beta)),width=40)
  
  df_tmp <- filter(total_df,tick==200*s,beta<0.5)
  bplot<-bplot + geom_boxplot(aes_string(x = 100*s+25,  y = df_tmp$AverageEmotionalState,fill=factor(df_tmp$beta)),width=40)
}
print(bplot)

# Boxplots
bplot <- ggplot()+ylim(0,0.1)+ theme + ggtitle("Zoom: Avg ES, full network, alpha=0.0, beta=[0.2,1.0]") + labs(x="ticks [10 min]",y="Average emotional state [-]",fill="beta")
for (s in 0:20) {
  df_tmp <- filter(total_df,tick==200*s,beta>=0.5)
  bplot<-bplot + geom_boxplot(aes_string(x = 100*s-25,  y = df_tmp$AverageEmotionalState,fill=factor(df_tmp$beta)),width=40)
  
  df_tmp <- filter(total_df,tick==200*s,beta<0.5)
  bplot<-bplot + geom_boxplot(aes_string(x = 100*s+25,  y = df_tmp$AverageEmotionalState,fill=factor(df_tmp$beta)),width=40)
}
print(bplot)


########### COMPARATIVE network

full_df <- read.csv("/home/daan/Desktop/Verification_results/Network_sampling_full.csv")
sparse_df <- read.csv("/home/daan/Desktop/Verification_results/Network_sampling_sparse.csv")

replications <- 45

tmp_full <- filter(full_df,Replication == 1,alpha==0.1)
max_full <- filter(tmp_full,AverageEmotionalState == max(tmp_full$AverageEmotionalState))

tmp_sparse <- filter(sparse_df,Replication == 1,alpha==0.1)
max_sparse <- filter(tmp_sparse,AverageEmotionalState == max(tmp_sparse$AverageEmotionalState))

for (rep in 2:replications) {
  tmp_full <- filter(full_df,Replication == rep,alpha==0.1)
  max_full <- rbind(max_full,filter(tmp_full,AverageEmotionalState == max(tmp_full$AverageEmotionalState)))
  
  tmp_sparse <- filter(sparse_df,Replication == rep,alpha==0.1)
  max_sparse <- rbind(max_sparse,filter(tmp_sparse,AverageEmotionalState == max(tmp_sparse$AverageEmotionalState)))
  
  
}

theme <- theme(plot.title = element_text(family = "Helvetica", size = (17.5)),
               legend.text = element_text(face = "italic", colour="black",family = "Helvetica"), 
               axis.title = element_text(family = "Helvetica", size = (17.5), colour = "black"),
               axis.text.x=element_blank())

bplot <- ggplot()+ ylim(0,1)+ theme + ggtitle("Boxplots max Avg ES, sparse/full network, alpha = 0.1, beta = [0.2, 1.0]") + labs(y="Max Average emotional state [-]",x="Full network                                         Sparse network") 
bplot<-bplot+geom_boxplot(aes_string(x=1,y=max_full$AverageEmotionalState),fill='lightgreen') + geom_boxplot(aes_string(x=2,y=max_sparse$AverageEmotionalState),fill='yellow')
print(bplot)










