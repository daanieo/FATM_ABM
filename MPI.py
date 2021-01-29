from mpi4py import MPI
import numpy as np
import pandas as pd

from singlethread_funcs import *

# This file has to be executed using mpiexec python filename.py to make use of the MPI functionality

# Set MPI environment
comm = MPI.COMM_WORLD
size = comm.Get_size()
rank = comm.Get_rank()

model_specifics = pd.read_csv("model_specifics.csv",index_col="Unnamed: 0")


# model-specifics
model_location_string = model_specifics["model_location_string"][0]#"/home/daan/GAMA/workspace/FATM_ABM/main/total_model/mechanical_model.gaml" # the location of the GAMA model
GAMA_location_string = model_specifics["GAMA_location_string"][0] #"/home/daan/GAMA" # the location of GAMA main folder
experiment_name = model_specifics["experiment_name"][0] #"simple_simulation" # experiment name as defined in the .gaml file
stopping_condition = model_specifics["stopping_condition"][0] #"cycle=10" # stopping condition (> or < do not work)

# Define general variables
outputdir = "results" # where to temporarily store the output xml files




# # make a list of names of parameters representing policy options
# policy_names = ["capacity_policy",
#                 "minfood_access_policy",
#                 "maxfood_access_policy",
#                 "day_access_policy",
#                 "rerouting_policy"]
# # state the policy options
# capacity_policy         = [0,1]
# minfood_access_policy   = [0,1]
# maxfood_access_policy   = [0,1,2]
# day_access_policy       = [0,1]
# rerouting_policy        = [0,1,2,3]
# # permutate the policy options
# res = [[i, j, k, l , m]  for i in capacity_policy
#                          for j in minfood_access_policy
#                          for k in maxfood_access_policy
#                          for l in day_access_policy
#                          for m in rerouting_policy]

# # Add one scenario to permutation
# uncertainty_dictionary = {}
# uncertainty_dictionary["normal"] = [0.5,0.5,3.0,0.5] # alpha,beta,gamma,epsilon
# parameter_values = list()
# for u in uncertainty_dictionary:
#     for p in res:
#         parameter_values.append(p+uncertainty_dictionary[u])

# # Add scenario factor names to list of parameters
# uncertainty_names = ["alpha","beta","gamma","epsilon"]
# parameter_names = policy_names+uncertainty_names

input_parameters = pd.read_csv("input_parameters.csv",index_col="Unnamed: 0")

# # List the names of the desired output
# output_names = [ "unsatisfied consumption",
#                  "food degraded",
#             	 "Queue length 0",
#                  "Queue length 1",
#             	 "Queue length 2",
#             	 "Queue length 3",
#             	 "Queue length 4",
#             	 "Queue length 5",
#             	 "Queue length 6",
#             	 "Queue length 7",
#             	 "Queue length 8",
#             	 "Queue length 9",
#             	 "Queue length 10",
#             	 "Queue length 11"]

output_names_import = pd.read_csv("output_names.csv",index_col="Unnamed: 0")
output_names = list()
for o in range(len(output_names_import)):
    output_names.append(output_names_import.iloc[o,0])
# Now we want to distribute the permutation over the threads


# Store the
sendbufdict={}
recvbufdict = {}

one_thread_loop_size = 2 #int(np.ceil(len(input_parameters)/size))

for stl in range(one_thread_loop_size):
    index = stl + rank*one_thread_loop_size
    #stl = 0

    if index < len(input_parameters):

        one_parameter_values = np.array(input_parameters.iloc[index,:]) #parameter_values[index]
        parameter_names = input_parameters.columns

        tempfile_location_string = create_input_XML(index,
                                                    parameter_names,
                                                    one_parameter_values,
                                                    output_names,
                                                    stopping_condition,
                                                    experiment_name,
                                                    outputdir,
                                                    model_location_string,
                                                    GAMA_location_string)


        output_location_string = run_model(index,tempfile_location_string,GAMA_location_string,outputdir)


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

    else:
        pass

for i in sendbufdict:
    comm.Gather(sendbufdict[i],recvbufdict[i],root=0)

if rank == 0:
    print(recvbufdict)
    pd.DataFrame(recvbufdict).to_feather("results/"+experiment_name)
