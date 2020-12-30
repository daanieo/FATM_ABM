
install.packages("foreach")
install.packages("doMC")
library(doMC)
registerDoMC(cores=4)
library(foreach)

lala <- function(n) {
  return(sum(n))
}

p_t <- t(params_sample)

foreach(n=p_t, .combine = rbind) %dopar% lala(n)

library(ggplot2)

p <- ggplot()#+xlim(0,cycles_in_day*days_runtime) +theme+ ggtitle("Emotional state: all value range") + labs(x="ticks [10 min]",y="Emotional state [-]",size=(200))
for (s in 0:(samplesize-1)) {
  until<-as.numeric(until)
  p<-p+geom_line(aes_string(x=as.numeric(df_tmp$tick[(s*until+1):((s+1)*until+1)]),y=as.numeric(df_tmp$EmotionalState[(s*until+1):((s+1)*until+1)]))) #
}
print(p)


# Plot the relevant model runs
replications <- 4
variations <- 18

p1<-ggplot()+ggtitle("Emotional state") + labs(x="ticks [10 min]",y="Emotional state [-]",size=(200))
p2<-ggplot()+ggtitle("Unsatisfied consumption") + labs(x="ticks [10 min]",y="Unsatisfied consumption [kg]",size=(200))
p3<-ggplot()+ggtitle("Distribution size") + labs(x="ticks [10 min]",y="Average distribution size [kg]",size=(200))
p4<-ggplot()+ggtitle("Queuing time") + labs(x="ticks [10 min]",y="Total queuing time [min]",size=(200))

c11 <- c()
c12 <- c()
c2 <- c()
c31 <-c()
c32 <- c()

for (simulation in 0:(replications*variations-1)){
  str<-paste0("/home/daan/GAMA/workspace/results/scaling_2k/sim",simulation,".csv")
  input <- t(read.csv(str,skip = 1,nrows=1,header=FALSE))
  data <- t(read.csv(str,header=FALSE,skip=2))
  
  if (max(data[,1]) < 0.25) {
    c11 <- append(c11,simulation) #print(paste0("Emotional state lower than 0.25 ",simulation))
  }
  # 
  if (max(data[,1]) > 0.875) {
    c12 <- append(c12,simulation) #print(paste0("Emotional state higher than 0.875 ",simulation))
  }
  # 
  if (max(data[,2]) > 100000) {
    c2 <- append(c2,simulation) #print(paste0("Unsatisfied consumption higher than 100,000 ",simulation))
  }
  # 
  if (75<max(data[,3]) || max(data[,3]) <100) {
    c31 <- append(c31,simulation) #print(paste0("Average distribution size between 75 and 100 ",simulation))
  }

  if (max(data[,3])>25) {
    c32 <- append(c32,simulation) #print(paste0("Average distribution size lower than 25 ",simulation))
  }
  
  p1<-p1+geom_line(aes_string(x=1:nrow(data),y=data[,1]))
  p2<-p2+geom_line(aes_string(x=1:nrow(data),y=data[,2]))
  p3<-p3+geom_line(aes_string(x=1:nrow(data),y=data[,3]))
  p4<-p4+geom_line(aes_string(x=1:nrow(data),y=data[,4]))
}

print(p1)
print(p2)
print(p3)
print(p4)
