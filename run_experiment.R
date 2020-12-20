# # The script:
# 1. Defines input parameters
# 2. Creates permutation of input parameters
# 3. Defines observables
# 4. Sets model path and further input (such as runtime)
# 5. Creates experiment XML files to feed to GAMA Headless
# 6. Fetches results from GAMA Headless
# 7. Stores in data.frame
# 8. Exports to csv

# Makes use of the following libraries
library(gamar)
library(XML)

# link gamar to preferred GAMA installation
setup_gama("/home/daan/GAMA")

# define to be researched parametres as c(min,max,stepsize) CHECK IF (max-min)%stepsize == 0 !
params = data.frame("ParallelServed"=c(1,10,1), "alpha"=c(0.1,0.1,0.1),"beta"=c(1.0,1.0,0.1),"gamma"=c(1.0,30.0,1.0))
#params = data.frame("alpha"=c(0.1,0.1,0.1),"beta"=c(1.0,1.0,0.1),"gamma"=c(1.0,30.0,1.0))

# create full list of all the to be researched entries 
params_list <- vector(mode="list", length=ncol(params))
# add names to list
names(params_list) <- names(params)

for (p in (1:ncol(params))){ # create list
  min <- params[1,p]
  max <- params[2,p]
  step <- params[3,p]
  
  tmplist <- c()
  for (i in 0:((max-min)/step)) {
    tmplist <- append(tmplist,min+step*i)
  }
  print(tmplist)
  params_list[[p]] <- tmplist
} 

# Create samples for all variables  !! not automatic 
params_sample <- expand.grid(params_list$ParallelServed,params_list$alpha,params_list$beta,params_list$gamma)
#params_sample <- expand.grid(params_list$alpha,params_list$beta,params_list$gamma)
names(params_sample) <- names(params)


# create dataframe for observations and corresponding framerate 
obs = data.frame("tick"=1,"AverageDeliverySize"=1,"QueueLength"=1,"FacilityStorage"=1)
# obs = data.frame("tick"=1,"AverageEmotionalState"=1)
# name the simulation 
simulation_id = "1"

# set path to model file 
path = "/home/daan/GAMA/workspace/FATM_ABM/main/facility_verification/facilities_test.gaml"
# path = "/home/daan/GAMA/workspace/FATM_ABM/main/household_verification/household_test.gaml"
# path = "/home/daan/GAMA/workspace/FATM_ABM/main/household_verification/network_test.gaml"

# give experiment name 
exp_name = "HouseholdsToFacility"

# till what tick 
cycles_in_day <- 6*24
days_runtime<-30
until = paste0(cycles_in_day*days_runtime)

# Function creating temporary XML to run the experiment 
createXML <- function(single_params,
                      obs,
                      simulation_id,
                      model_path,
                      exp_name,
                      until) {
  tmp_xml = tempfile(fileext = ".xml")
  
  # Empty XML tree
  xml<-xmlTree() # Empty XML tree
  xml$addTag("Experiment_plan",close=FALSE) # Experiment layer
  xml$addTag("Simulation",close=FALSE, attrs=c(id=paste0(simulation_id), sourcePath=paste0(model_path), finalStep=paste0(until),experiment=paste0(exp_name))) # Simulation layer
  xml$addTag("Parameters",close=FALSE) # Parameters layer
  
  # Add all paramaters and values 
  for (i in 1:ncol(single_params)) {
    xml$addTag("Parameter",attrs=c(name=colnames(single_params)[i],type="FLOAT",value=single_params[1,i]))
  }
  xml$closeTag()
  
  xml$addTag("Outcomes",close=FALSE) # Outcome layer
  
  # Add all outcomes
  for (i in 1:ncol(obs)) {
    xml$addTag("Output",attrs=c(id = paste0(i), name=colnames(obs)[i],framerate=obs[1,i]))
  }
  
  xml$closeTag()
  xml$closeTag()
  xml$closeTag()
  
  saveXML(xml,file=tmp_xml)
  
  return(tmp_xml)
}

# time before
tb <- Sys.time()

# empty df 
total_df <- NULL

# for the entire sample list 
for (run in 1:nrow(params_sample)){
  
  # temporary experiment xml
  tmp_xml <- createXML(single_params = params_sample[run,],obs=obs,simulation_id = simulation_id,model_path = path,exp_name = exp_name,until=until)
  tmp_dir <- tempdir() # temporary dir to store outcome xml
  message("call gama model")
  call_gama(tmp_xml,hpc=2,output_dir = tmp_dir) # run gama model
  
  message("import outcome xml")
  # import outcome xml 
  tmp_df<-XML::xmlToDataFrame(XML::xmlParse(paste0(tmp_dir,"/","simulation-outputs1.xml")), stringsAsFactors = FALSE)
  # add column names
  names(tmp_df)<-colnames(obs)
  
  # delete temporary xml files
  unlink(paste0(tmp_dir,"/","simulation-outputs1.xml"))
  unlink(tmp_xml)
  
  for (p in 1:ncol(params_sample)){
    tmpcol <- rep(params_sample[run,p],until)
    
    tmp_df <- cbind(tmpcol,tmp_df)
    names(tmp_df)[1] <- names(params_sample)[p]
  }
  
  # add to existing dataframe 
  if (is.null(total_df)){
    total_df<-tmp_df
  } else{
    total_df <- rbind(total_df, tmp_df)
  }
  
}


# Write results to csv
write.csv(total_df,paste0("/home/daan/Desktop/",exp_name,".csv"))

ta <- Sys.time()

message("took me ",ta-tb)




