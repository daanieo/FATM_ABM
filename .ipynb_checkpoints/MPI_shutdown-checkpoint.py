from mpi4py import MPI
import numpy as np
import pandas as pd

from singlethread_funcs import *

# This file has to be executed using mpiexec python filename.py to make use of the MPI functionality

# Set MPI environment
comm = MPI.COMM_WORLD
size = comm.Get_size()
rank = comm.Get_rank()

# Parse model specific setup parametres and set to variables
model_specifics = pd.read_csv("model_specifics.csv",index_col="Unnamed: 0") 
model_location_string = model_specifics["model_location_string"][0]
GAMA_location_string = model_specifics["GAMA_location_string"][0] 
experiment_name = model_specifics["experiment_name"][0] 
stopping_condition = model_specifics["stopping_condition"][0] 

# Define general variables
outputdir = "results" # where to temporarily store the output xml files

# Read input parameters from .csv file, generated in a Notebook
input_parameters = pd.read_csv("input_parameters.csv",index_col="Unnamed: 0")

# Read output names from .csv file, generated in a Notebook
output_names_import = pd.read_csv("output_names.csv",index_col="Unnamed: 0")
output_names = list()
for o in range(len(output_names_import)):
    output_names.append(output_names_import.iloc[o,0])
    
# Dictionary to store model output per thread
sendbufdict = {}

# Dictionary to store model output on root thread; a collection of sendbufdicts 
recvbufdict = {}

# Max number of model runs per thread 
one_thread_loop_size = int(np.ceil(len(input_parameters)/size))

for stl in range(one_thread_loop_size):
    index = stl + rank*one_thread_loop_size
    
    if index < len(input_parameters): # Index not exceeding the length of input parameters
        pass
    else:
        index=0
        
    one_parameter_values = np.array(input_parameters.iloc[index,:]) # List of parametres for one run 
    parameter_names = input_parameters.columns # List of parameter names

    # Generate temporary input .XML file
    tempfile_location_string = create_input_XML(index,
                                                parameter_names,
                                                one_parameter_values,
                                                output_names,
                                                stopping_condition,
                                                experiment_name,
                                                outputdir,
                                                model_location_string,
                                                GAMA_location_string)

    # Generate temporary output .xml file
    output_location_string = run_model(index,tempfile_location_string,GAMA_location_string,outputdir)

    # Parse and delete temporary output file
    one_outputs = parse_output_XML( unique_simulation_id = index,
                                    output_location_string = output_location_string,
                                    output_names = output_names)


    # store according to r(eplication)n_o(utput)m
    for o in range(len(one_outputs)):
        if stl == 0:
            sendbufdict["o%s"%(o)] = np.array(one_outputs[o],dtype='float')
            recvbufdict["o%s"%(o)] = np.empty(size*len(one_outputs[o]), dtype='float')

        else:
            sendbufdict["o%s"%(o)] = np.concatenate( (sendbufdict["o%s"%(o)], np.array(one_outputs[o],dtype='float')) )
            recvbufdict["o%s"%(o)] = np.concatenate( (recvbufdict["o%s"%(o)],  np.empty(size*len(one_outputs[o]), dtype='float') ) )



# Collect thread-wise output storage from sendbufdict to recvbufdict
for i in sendbufdict:
    comm.Gather(sendbufdict[i],recvbufdict[i],root=0)

# Export recvbufdict to Feather file from the root thread 
if rank == 0:
    print("Exporting...")
    pd.DataFrame(recvbufdict).to_feather("results/"+experiment_name)
    
    os.system("shutdown now") 
