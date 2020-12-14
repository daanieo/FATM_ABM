# Makes use of the following libraries
library(gamar)
library(XML)

# link gamar to preferred GAMA installation
setup_gama("/home/daan/GAMA")

# define to be researched parametres as c(min,max,stepsize) CHECK IF (max-min)%stepsize == 0 !
params = data.frame("alpha"=c(0.1,0.3,0.1),"beta"=c(0.9,1.0,0.1))

# create full list of all the to be researched entries 
params_list <- vector(mode="list", length=ncol(params))
# add names to list
names(params_list) <- names(params)

for (p in (1:ncol(params))){ # create list
  min <- params[1,p]
  max <- params[2,p]
  step <- params[3,p]
  
  tmplist <- c(min)
  for (i in 1:((max-min)/step)) {
    tmplist <- append(tmplist,min+step*i)
  }
  print(tmplist)
  params_list[[p]] <- tmplist
} 

# Create samples for all variables
params_sample <- expand.grid(params_list$alpha,params_list$beta)
names(params_sample) <- names(params)


# create dataframe for observations and corresponding framerate 
obs = data.frame("avgemo"=1,"uc"=10)

# name the simulation 
simulation_id = "1"

# set path to model file 
path = "/home/daan/GAMA/workspace/FATM_ABM/main/household_verification/households_test.gaml"

# give experiment name 
exp_name = "GoWithR"

# till what tick 
until = "1000"

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

# empty df 
total_df <- NULL

# for the entire sample list 
for (run in 1:nrow(params_sample)){
  
  # temporary experiment xml
  tmp_xml <- createXML(single_params = params_sample[run,],obs=obs,simulation_id = simulation_id,model_path = path,exp_name = exp_name,until=until)
  tmp_dir <- tempdir() # temporary dir to store outcome xml
  call_gama(tmp_xml,hpc=2,output_dir = tmp_dir) # run gama model
  
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
write.csv(total_df,"/home/daan/Desktop/results.csv")










