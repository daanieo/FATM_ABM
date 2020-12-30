/**
* Name: Zone02_simulation
* Based on the internal empty template. 
* Author: daan
* Tags: 
*/


model mechanical_model

import "facilities_model2.gaml"
import "households_model2.gaml"


global {
	file shape_file_buildings <- shape_file("/home/daan/Documents/input_files/building_polygons/filtered/2217.shp","EPSG:4326");
//	file shape_file_buildings <- shape_file("/home/daan/Documents/input_files/building_polygons/filtered/3022.shp","EPSG:4326");
//	file shape_file_buildings <- shape_file("/home/daan/Documents/input_files/building_polygons/filtered/6650.shp","EPSG:4326");
//	file shape_file_buildings <- shape_file("/home/daan/Documents/input_files/building_polygons/filtered/33249.shp","EPSG:4326");

	file shape_file_facilities <- shape_file("/home/daan/Documents/FATM_opt/save_files/gdf_0f/gdf_0f.shp","EPSG:4326");
	geometry shape <-envelope(shape_file_buildings);
	
	int scaling_factor <- 15;
//	int scaling_factor <- 11; 
//	int scaling_factor <- 5;
//	int scaling_factor <- 1;

//	Experiment-variable and potential vital variable
	int nb_households <- round(2500/scaling_factor);
	int parallel_served_full <- 5;
	int avg_interactions <- 5;
	float alpha <- 0.1;
	float beta <- 1.0;
	float gamma <-10.0;
	float epsilon<-0.5;  
	
	float parallel_served <- parallel_served_full/scaling_factor;
	int avg_hh_size<-7;
		
//	Time-related constants
	date starting_date <- date("2021-01-01 00:00:00");	
	float step <- 10 #minutes;
	int cycles_in_hour <- 6;
	int cycles_in_day <- 24*6; 
//	Facilities
	int opening_hour <- 8;
	int closing_hour <- 20;
//	Households
	int wake_up <- 6;
	int go_sleep <- 23;
	
//	Statistics
	list<float> avg_es <- []; // avg emotional state
	list<float> sum_uc <- []; // unsatisfied consumption
	list<float> sum_fd <- []; // avg distribution size
	list<float> avg_qs <- []; // avg queuing size 

	

	init {

//		Create facility agents
		create facilities from: shape_file_facilities { 
									
//			Assign empties to variables 
			nb_beneficiaries <- 0; // the number of people a facility is supposed to serve 
			queue <- [];
			queue_open<-true;
			facility_food_storage <- nb_households*15/scaling_factor; // At initialisation, food storage has max capacity 
			
//			Initialise statistics
			food_served <- 0.0;
			nb_served <-1;
			unsatisfied_demand <- 0.0;

		}
		
//		Create household agents
		create households from: shape_file_buildings{
			
//			Constants
			ration <- 15.0; 				// kg rice / pers / month
			infected_threshold <- 0.5;				// threshold to changing the agent to be "infected"
			home_location <- location;				// home location = current location 
			speed <- 4 #km/#hour;					// speed of beneficiaries 
			social_network <- [];
			
	
//			Unique constants
			nb_members <- rnd(avg_hh_size-3,avg_hh_size+3); // houshold size equally varying between 4 and 10 
			pc<- rnd(0,9)/10; 						// personal characteristic varying between 0 and 1
			home_location <- location;				// home location = current location 
			my_facility <- determine_facility();	// home facility is current closest facility 
					
			
//			Variables
			food_storage <- ration/30 * gamma * nb_members + rnd(0,gamma)*nb_members*ration/30;			// initial food storage 
			emotional_state <- 0.0;
			emotional_timestamp <- 0;
			facility_of_choice <- my_facility;	// initally facility of choice is my facility 
			degraded_food <- 0.0;
			
//			States			
			incentive_to_facility <- false;
			incentive_to_home <- false;
				
//			Initialise statistics	
			unsatisfied_consumption <- 0.0;
//			queuing_time <- 0.0;
					
//			Add the number of household members to the facility			
			ask my_facility {
				nb_beneficiaries <- nb_beneficiaries + myself.nb_members; 
			}			
		} 
	}
	
	reflex t {
		
		add (households sum_of each.unsatisfied_consumption) to: sum_uc;
		add (households mean_of each.emotional_state) to: avg_es;
		add (households sum_of each.degraded_food) to: sum_fd;
		
	}
	

	
}





experiment simple_simulation keep_seed: true type: gui until: (cycle>(30*cycles_in_day)){
	
	parameter "alpha" var: alpha min: 0 max: 1 step: 0.01;
	parameter "beta" var: beta min:0 max: 1 step: 0.1;
 	parameter "gamma" var: gamma min:1 max: 30 step:1;
 	parameter "epsilon" var: epsilon min: 0 max: 1 step: 0.1; 
 	
 	parameter "avg_interactions" var: avg_interactions min: 0 max: 10 step: 1;

 	parameter "Est. facility capacity per cycle" var: parallel_served_full min: 1 max:100 step: 1;
	

		
	output {

		
	display data_viz {
       	chart "avg es" type: series y_label: "kg rice" y_range:[-0.1,1] x_range: [0,4000] size: {0.5,0.5} position: {0.5, 0}{
        data "average emotional state" value: households mean_of each.emotional_state;
        

    }    
       	chart "Facilities queue lengths" type: series y_label: "# people" y_range:[0,2500] x_range: [0,4000]size: {1.0,0.5} position: {0, 0.5} {
        loop f over: facilities {
    		data f.name value: length(f.queue);
		}

    }
    
    	chart "summed food storage of household" type: series y_label: "summed food" y_range:[0,315000] x_range: [0,4000] size: {0.5,0.5} position: {0,0} {
    		data "summed food" value: households sum_of each.food_storage;
    	}
	  
	}
	
	monitor "Queue length 0" value: length(facilities[0].queue);
	monitor "Queue length 1" value: length(facilities[1].queue);
	monitor "Queue length 2" value: length(facilities[2].queue);
	monitor "Queue length 3" value: length(facilities[3].queue);
	monitor "Queue length 4" value: length(facilities[4].queue);
	monitor "Queue length 5" value: length(facilities[5].queue);
	monitor "Queue length 6" value: length(facilities[6].queue);
	monitor "Queue length 7" value: length(facilities[7].queue);
	monitor "Queue length 8" value: length(facilities[8].queue);
	monitor "Queue length 9" value: length(facilities[9].queue);
	monitor "Queue length 10" value: length(facilities[10].queue);
	monitor "Queue length 11" value: length(facilities[11].queue);
	
	monitor "avg es" value: households mean_of each.emotional_state;
	monitor "unsatisfied consumption" value: households sum_of each.unsatisfied_consumption;
	
	monitor "average serving size" value: (facilities sum_of each.food_served) / (facilities sum_of each.nb_served);
	
	monitor "food degraded" value: households sum_of each.degraded_food;
		
	}
}


experiment batch_experiment type: batch keep_seed: true repeat: 4 until: (cycle>(30*cycles_in_day)){
	
	parameter "alpha" var: alpha min: 0.1 max: 0.5 step: 0.4; // 2
	parameter "beta" var: beta min:0.05 max: 0.55 step: 0.5; // 2
 	parameter "gamma" var: gamma min:5 max: 30 step: 25; // 2
 	parameter "epsilon" var: epsilon min: 0.2 max: 1.0 step: 0.8; //2 

 	
 	parameter "avg_interactions" var: avg_interactions min: 0 max: 5 step: 5; // 2

 	parameter "Est. facility capacity per cycle" var: parallel_served_full min: 2 max:10 step: 8; //2
	
	int sim <-0;
	int nb_sims <- 10 * 2*2*2*2*2*2 ;
	

	
	reflex t {
		
		string outcomes_sum_fd <- "";
		string outcomes_input <- "";
		string outcomes_avg_es <- "";
		string outcomes_es <- "";
		string outcomes_sum_uc<- "";
		string outcomes_uc <- "";
		string outcomes_ql <- "";
		string outcomes_fs_p <- "";
			
		int rep<-0;
		
		ask simulations {
			
			outcomes_input <- outcomes_input + rep+ "," + string(alpha) + ","+beta+","+gamma+","+epsilon+","+avg_interactions+","+parallel_served_full+"\n";
			
			// Add the average emotional state to the outcome string 
			loop v over: avg_es{
				outcomes_avg_es <- outcomes_avg_es + ","+v;
			}
			outcomes_avg_es<-outcomes_avg_es+"\n";
	
			// Add the unsatisfied consumption to the outcome string 
			loop v over: sum_uc{
				outcomes_sum_uc <- outcomes_sum_uc + ","+v;
			}
			outcomes_sum_uc<-outcomes_sum_uc+"\n";		
			
			// Add the food degradation to the outcome string 
			loop v over: sum_fd{
				outcomes_sum_fd <- outcomes_sum_fd + ","+v;
			}
			outcomes_sum_fd<-outcomes_sum_fd+"\n";		
			
			loop f over: facilities{
				outcomes_ql <- outcomes_ql + rep + "," + f.name;
				loop v over: f.length_of_queue{
					outcomes_ql <- outcomes_ql + "," + v;
				}
				outcomes_ql <- outcomes_ql + "\n"; 
			}
			
			save outcomes_input to: "/home/daan/GAMA/workspace/results/scaling_2k/outcomes_input_sim"+myself.sim+"_rep"+rep+".csv" type: "csv";
			save outcomes_avg_es to: "/home/daan/GAMA/workspace/results/scaling_2k/outcomes_avg_es_sim"+myself.sim+"_rep"+rep+".csv" type: "csv";
			save outcomes_sum_uc to: "/home/daan/GAMA/workspace/results/scaling_2k/outcomes_sum_uc_sim"+myself.sim+"_rep"+rep+".csv" type: "csv";
			save outcomes_sum_fd to: "/home/daan/GAMA/workspace/results/scaling_2k/outcomes_sum_fd_sim"+myself.sim+"_rep"+rep+".csv" type: "csv";
			
			// Individual facility
			save outcomes_ql to: "/home/daan/GAMA/workspace/results/scaling_2k/outcomes_ql_sim"+myself.sim+"_rep"+rep+".csv" type: "csv";
			
			// Statistics collected each day per household. 
//			loop h over: households{
//				myself.outcomes_uc <- myself.outcomes_uc + myself.sim + "," + h.name;
//				myself.outcomes_es <- myself.outcomes_es + myself.sim + "," + h.name;
//				myself.outcomes_fs_p <- myself.outcomes_fs_p + myself.sim + "," + h.name;
//
//				loop v1 over: h.uc{
//					myself.outcomes_uc <- myself.outcomes_uc + "," + v1;
//				}
//				loop v2 over: h.es{
//					myself.outcomes_es <- myself.outcomes_es + "," + v2;
//				}
//				loop v3 over: h.fs_p{
//					myself.outcomes_fs_p <- myself.outcomes_fs_p+ ","+v3;
//				}
//				myself.outcomes_es <- myself.outcomes_es + "\n";
//				myself.outcomes_uc <- myself.outcomes_uc + "\n"; 
//				myself.outcomes_fs_p <- myself.outcomes_fs_p + "\n";
//			}
			
									
			rep<-rep+1;
		}
			
	
//		write "saving shit simulation "+sim;
//		save outcomes_input to: "/home/daan/GAMA/workspace/results/scaling_2k/outcomes_input_sim"+sim+".csv" type: "csv";
//		save outcomes_avg_es to: "/home/daan/GAMA/workspace/results/scaling_2k/outcomes_avg_es_sim"+sim+".csv" type: "csv";
//		save outcomes_sum_uc to: "/home/daan/GAMA/workspace/results/scaling_2k/outcomes_sum_uc_sim"+sim+".csv" type: "csv";
//		save outcomes_sum_fd to: "/home/daan/GAMA/workspace/results/scaling_2k/outcomes_sum_fd_sim"+sim+".csv" type: "csv";
//		
//		// Individual facility
//		save outcomes_ql to: "/home/daan/GAMA/workspace/results/scaling_2k/outcomes_ql_sim"+sim+".csv" type: "csv";
		
//		// Individual household
//		save outcomes_uc to: "/home/daan/GAMA/workspace/results/scaling_2k/outcomes_uc.csv" type: "csv";
//		save outcomes_es to: "/home/daan/GAMA/workspace/results/scaling_2k/outcomes_es.csv" type: "csv";	
//		save outcomes_fs_p to: "/home/daan/GAMA/workspace/results/scaling_2k/outcomes_fs_p.csv" type: "csv";		

		sim<-sim+1;

	}
}















