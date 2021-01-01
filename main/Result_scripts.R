

library(ggplot2)


# Plot the relevant model runs
replications <- 4
variations <- 324

p1<-ggplot()+ggtitle("Emotional state") + labs(x="ticks [10 min]",y="Emotional state [-]",size=(200))
p2<-ggplot()+ggtitle("Unsatisfied consumption") + labs(x="ticks [10 min]",y="Unsatisfied consumption [kg]",size=(200))
p3<-ggplot()+ggtitle("Distribution size") + labs(x="ticks [10 min]",y="Average distribution size [kg]",size=(200))
p4<-ggplot()+ggtitle("Queuing time") + labs(x="ticks [10 min]",y="Total queuing time [min]",size=(200))



input_df <- NULL
ql_df<-NULL
sum_fd_df<-NULL
sum_uc_df<-NULL
avg_es_df<-NULL

for (var in 0:(variations-1)) {
    message(var)
    for (rep in 0:(replications-1)){
      message(rep)
      ql_str <- paste0("/home/daan/GAMA/workspace/results/uncap_2k/outcomes_ql_sim",var,"_rep",rep,".csv")
      input_str <-  paste0("/home/daan/GAMA/workspace/results/uncap_2k/outcomes_input_sim",var,"_rep",rep,".csv")
      avg_es_str <- paste0("/home/daan/GAMA/workspace/results/uncap_2k/outcomes_avg_es_sim",var,"_rep",rep,".csv")
      sum_fd_str <- paste0("/home/daan/GAMA/workspace/results/uncap_2k/outcomes_sum_fd_sim",var,"_rep",rep,".csv")
      sum_uc_str <- paste0("/home/daan/GAMA/workspace/results/uncap_2k/outcomes_sum_uc_sim",var,"_rep",rep,".csv")
      
      ql_input<-read.csv(ql_str,skip=1,header = FALSE)
      input_input<-read.csv(input_str,skip=1,header = FALSE)
      avg_es_input<-read.csv(avg_es_str,skip=1,header = FALSE)
      sum_fd_input<-read.csv(sum_fd_str,skip=1,header = FALSE)
      sum_uc_input<-read.csv(sum_uc_str,skip=1,header = FALSE)

      if (is.null(input_df)){
        input_df <- input_input[,3:ncol(input_input)]
        ql_df <- ql_input[,2:ncol(ql_input)]
        sum_fd_df <- sum_fd_input[,3:ncol(sum_fd_input)]
        sum_uc_df <- sum_uc_input[,3:ncol(sum_uc_input)]
        avg_es_df <- avg_es_input[,3:ncol(avg_es_input)]
      } else {
        input_df <- rbind(input_df,input_input[,3:ncol(input_input)])
        ql_df <- rbind(ql_df,ql_input[,2:ncol(ql_input)])
        sum_fd_df <- rbind(sum_fd_df,sum_fd_input[,3:ncol(sum_fd_input)])
        sum_uc_df <- rbind(sum_uc_df,sum_uc_input[,3:ncol(sum_uc_input)])
        avg_es_df <- rbind(avg_es_df,avg_es_input[,3:ncol(avg_es_input)])
      }

      
    }
}

write.csv(input_df,"/home/daan/Desktop/input.csv")
write.csv(ql_df,"/home/daan/Desktop/ql.csv")
write.csv(sum_fd_df,"/home/daan/Desktop/sum_fd.csv")
write.csv(sum_uc_df,"/home/daan/Desktop/sum_uc.csv")
write.csv(avg_es_df,"/home/daan/Desktop/avg_es.csv")


p1<-ggplot()+ggtitle("Average emotional state") + labs(x="ticks [10 min]",y="Emotional state [-]",size=(200))
p2<-ggplot()+ggtitle("Unsatisfied consumption") + labs(x="ticks [10 min]",y="Unsatisfied consumption [kg]",size=(200))
p3<-ggplot()+ggtitle("Food degradation") + labs(x="ticks [10 min]",y="Food subject to degradation [kg]",size=(200))
p4<-ggplot()+ggtitle("Queuing time") + labs(x="ticks [10 min]",y="Total queuing time [min]",size=(200))

for (entry in 1:nrow(avg_es_df)){
  p1<-p1+geom_line(aes_string(x=1:ncol(avg_es_df),y=t(avg_es_df)[,entry]))
  p2<-p2+geom_line(aes_string(x=1:ncol(sum_fd_df),y=t(sum_fd_df)[,entry]))
  p3<-p3+geom_line(aes_string(x=1:ncol(sum_uc_df),y=t(sum_uc_df)[,entry]))
  
}

print(p1)
print(p2)
print(p3)


