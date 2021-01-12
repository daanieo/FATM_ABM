

library(ggplot2)


capacity_policies <- c("capacitated","uncapacitated")
access_policies <- c("base","far","tar")
rerouting_policies <- c("base","rr1","rr2")

# Plot the relevant model runs
replications <- 4
variations <- 16
simulation <- 0
for (cp in capacity_policies) {
  for (ap in access_policies) {
    for (rp in rerouting_policies) {
      
      experiment_name <- paste0(cp,"_",ap,"_",rp)
      message(experiment_name)
      input_df <- NULL
      ql_df<-NULL
      sum_fd_df<-NULL
      sum_uc_df<-NULL
      avg_es_df<-NULL
      
      for (var in 0:(variations-1)) {
        
        message("variation ",var)
        for (rep in 0:(replications-1)){
          message(rep)
          ql_str <- paste0("/home/daan/GAMA/workspace/results/",experiment_name,"/outcomes_ql_sim",simulation,"_rep",rep,".csv")
          input_str <-  paste0("/home/daan/GAMA/workspace/results/",experiment_name,"/outcomes_input_sim",simulation,"_rep",rep,".csv")
          avg_es_str <- paste0("/home/daan/GAMA/workspace/results/",experiment_name,"/outcomes_avg_es_sim",simulation,"_rep",rep,".csv")
          sum_fd_str <- paste0("/home/daan/GAMA/workspace/results/",experiment_name,"/outcomes_sum_fd_sim",simulation,"_rep",rep,".csv")
          sum_uc_str <- paste0("/home/daan/GAMA/workspace/results/",experiment_name,"/outcomes_sum_uc_sim",simulation,"_rep",rep,".csv")
          
          ql_input<-read.csv(ql_str,skip=1,header = FALSE)
          input_input<-read.csv(input_str,skip=1,header = FALSE)
          avg_es_input<-read.csv(avg_es_str,skip=1,header = FALSE)
          sum_fd_input<-read.csv(sum_fd_str,skip=1,header = FALSE)
          sum_uc_input<-read.csv(sum_uc_str,skip=1,header = FALSE)
          
          if (is.null(input_df)){
            input_df <- input_input#[,3:ncol(input_input)]
            ql_df <- ql_input[,3:ncol(ql_input)]
            sum_fd_df <- sum_fd_input[,1:ncol(sum_fd_input)]
            sum_uc_df <- sum_uc_input[,1:ncol(sum_uc_input)]
            avg_es_df <- avg_es_input[,1:ncol(avg_es_input)]
          } else {
            input_df <- rbind(input_df,input_input)#[,3:ncol(input_input)])
            ql_df <- rbind(ql_df,ql_input[,3:ncol(ql_input)])
            sum_fd_df <- rbind(sum_fd_df,sum_fd_input[,1:ncol(sum_fd_input)])
            sum_uc_df <- rbind(sum_uc_df,sum_uc_input[,1:ncol(sum_uc_input)])
            avg_es_df <- rbind(avg_es_df,avg_es_input[,1:ncol(avg_es_input)])
          }
          
          
        }
      simulation <- simulation+1
      }
      
      write.csv(input_df,paste0("/home/daan/Desktop/",experiment_name,"_input.csv"))
      write.csv(ql_df,paste0("/home/daan/Desktop/",experiment_name,"_ql.csv"))
      write.csv(sum_fd_df,paste0("/home/daan/Desktop/",experiment_name,"_sum_fd.csv"))
      write.csv(sum_uc_df,paste0("/home/daan/Desktop/",experiment_name,"_sum_uc.csv"))
      write.csv(avg_es_df,paste0("/home/daan/Desktop/",experiment_name,"_avg_es.csv"))
    }
  }
}



# 
# experiment_name <- "tar_uncapacitated"
# 
# # p1<-ggplot()+ggtitle("Emotional state") + labs(x="ticks [10 min]",y="Emotional state [-]",size=(200))
# # p2<-ggplot()+ggtitle("Unsatisfied consumption") + labs(x="ticks [10 min]",y="Unsatisfied consumption [kg]",size=(200))
# # p3<-ggplot()+ggtitle("Distribution size") + labs(x="ticks [10 min]",y="Average distribution size [kg]",size=(200))
# # p4<-ggplot()+ggtitle("Queuing time") + labs(x="ticks [10 min]",y="Total queuing time [min]",size=(200))
# # 
# 
# 
# input_df <- NULL
# ql_df<-NULL
# sum_fd_df<-NULL
# sum_uc_df<-NULL
# avg_es_df<-NULL
# 
# for (var in 0:(variations-1)) {
#     message(var)
#     for (rep in 0:(replications-1)){
#       message(rep)
#       ql_str <- paste0("/home/daan/GAMA/workspace/results/",experiment_name,"/outcomes_ql_sim",var,"_rep",rep,".csv")
#       input_str <-  paste0("/home/daan/GAMA/workspace/results/",experiment_name,"/outcomes_input_sim",var,"_rep",rep,".csv")
#       avg_es_str <- paste0("/home/daan/GAMA/workspace/results/",experiment_name,"/outcomes_avg_es_sim",var,"_rep",rep,".csv")
#       sum_fd_str <- paste0("/home/daan/GAMA/workspace/results/",experiment_name,"/outcomes_sum_fd_sim",var,"_rep",rep,".csv")
#       sum_uc_str <- paste0("/home/daan/GAMA/workspace/results/",experiment_name,"/outcomes_sum_uc_sim",var,"_rep",rep,".csv")
#       
#       ql_input<-read.csv(ql_str,skip=1,header = FALSE)
#       input_input<-read.csv(input_str,skip=1,header = FALSE)
#       avg_es_input<-read.csv(avg_es_str,skip=1,header = FALSE)
#       sum_fd_input<-read.csv(sum_fd_str,skip=1,header = FALSE)
#       sum_uc_input<-read.csv(sum_uc_str,skip=1,header = FALSE)
# 
#       if (is.null(input_df)){
#         input_df <- input_input#[,3:ncol(input_input)]
#         ql_df <- ql_input[,3:ncol(ql_input)]
#         sum_fd_df <- sum_fd_input[,1:ncol(sum_fd_input)]
#         sum_uc_df <- sum_uc_input[,1:ncol(sum_uc_input)]
#         avg_es_df <- avg_es_input[,1:ncol(avg_es_input)]
#       } else {
#         input_df <- rbind(input_df,input_input)#[,3:ncol(input_input)])
#         ql_df <- rbind(ql_df,ql_input[,3:ncol(ql_input)])
#         sum_fd_df <- rbind(sum_fd_df,sum_fd_input[,1:ncol(sum_fd_input)])
#         sum_uc_df <- rbind(sum_uc_df,sum_uc_input[,1:ncol(sum_uc_input)])
#         avg_es_df <- rbind(avg_es_df,avg_es_input[,1:ncol(avg_es_input)])
#       }
# 
#       
#     }
# }
# 
# write.csv(input_df,paste0("/home/daan/Desktop/",experiment_name,"/input.csv"))
# write.csv(ql_df,paste0("/home/daan/Desktop/",experiment_name,"/ql.csv"))
# write.csv(sum_fd_df,paste0("/home/daan/Desktop/",experiment_name,"/sum_fd.csv"))
# write.csv(sum_uc_df,paste0("/home/daan/Desktop/",experiment_name,"/sum_uc.csv"))
# write.csv(avg_es_df,paste0("/home/daan/Desktop/",experiment_name,"/avg_es.csv"))
# 
# input_df <- read.csv(paste0("/home/daan/Desktop/",experiment_name,"/input.csv"))
# ql_df <- read.csv(paste0("/home/daan/Desktop/",experiment_name,"/ql.csv"))
# sum_fd_df <- read.csv(paste0("/home/daan/Desktop/",experiment_name,"/sum_fd.csv"))
# sum_uc_df <- read.csv(paste0("/home/daan/Desktop/",experiment_name,"/sum_uc.csv"))
# avg_es_df <- read.csv(paste0("/home/daan/Desktop/",experiment_name,"/avg_es.csv"))
# 
# 
# 
# p1<-ggplot()+ggtitle("Average emotional state") + labs(x="ticks [10 min]",y="Emotional state [-]",size=(200))
# p2<-ggplot()+ggtitle("Unsatisfied consumption") + labs(x="ticks [10 min]",y="Unsatisfied consumption [kg]",size=(200))
# p3<-ggplot()+ggtitle("Food degradation") + labs(x="ticks [10 min]",y="Food subject to degradation [kg]",size=(200))
# p4<-ggplot()+ggtitle("Queuing time") + labs(x="ticks [10 min]",y="Total queuing time [min]",size=(200))
# 
# till <- 100
# 
# f1 <- rep(0,nrow(avg_es_df))
# f2 <- rep(0,nrow(avg_es_df))
# f3 <- rep(0,nrow(avg_es_df))
# 
# for (entry in 2:(nrow(avg_es_df)/4)){
#   # f1[entry] <- max( t(avg_es_df)[2:nrow(avg_es_df),entry] )
#   # f2[entry] <- max( t(sum_fd_df)[2:nrow(sum_fd_df),entry] )
#   # f3[entry] <- max( t(sum_uc_df)[2:nrow(sum_uc_df),entry] )
#   # 
#   
#   p1<-p1+geom_line(aes_string(x=1:ncol(avg_es_df),y=t(avg_es_df)[,entry*4]))
#   p2<-p2+geom_line(aes_string(x=1:ncol(sum_fd_df),y=t(sum_fd_df)[,entry*4]))
#   p3<-p3+geom_line(aes_string(x=1:ncol(sum_uc_df),y=t(sum_uc_df)[,entry*4]))
#   
# }
# 
# 
# 
# f4 <- filter(ql_df, X%%48==0)
# f4 <- f4[,3:ncol(f4)]
# 
# for (entry in 1:(nrow(f4)/2)){
#   tmp <- as.numeric(f4[entry,])
#   message(entry)
#   p4<-p4+geom_line(aes_string(x=1:(length(tmp)),y=tmp))
#   
# }
# print(p4)
# 
# ggplot() + boxplot(f1)
# ggplot()+ boxplot(f2)
# ggplot() + boxplot(f3)
# 
# ggplot() + geom_point(aes(x=rep(0,1296),y=f1))
# ggplot() + geom_point(aes(x=rep(0,1296),y=f2))
# ggplot() + geom_point(aes(x=rep(0,1296),y=f3))
# 
# library(dplyr)
# 
# y<-filter(sum_uc_df,f3<15000,f3>5000)
# for (entry in 1:nrow(y)){
#   p3<-p3+geom_line(aes_string(x=1:ncol(y),y=t(y)[,entry]))
# 
# }
# 
# sum_uc_df[15000>f3][f3>5000]
# sum_uc_df[20000>f3][f3>15000]
# sum_uc_df[f3>30000]
# 
# print(p1)
# print(p2)
# print(p3)



