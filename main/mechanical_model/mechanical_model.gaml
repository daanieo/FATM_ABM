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
	float epsilon<-0.0;  
	
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
	list<float> uc <- []; // unsatisfied consumption
	list<float> avg_ds <- []; // avg distribution size
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
			
//			States			
			incentive_to_facility <- false;
			incentive_to_home <- false;
				
//			Initialise statistics	
			unsatisfied_consumption <- 0.0;
			queuing_time <- 0.0;
					
//			Add the number of household members to the facility			
			ask my_facility {
				nb_beneficiaries <- nb_beneficiaries + myself.nb_members; 
			}			
		} 
	}
	
	reflex t {
		
		float sum_served <- facilities sum_of each.food_served;
		float nb_served <- facilities sum_of each.nb_served;
		add (sum_served/nb_served) to: avg_ds;
		add (households mean_of each.queuing_time) to: avg_qs;		
		add (households sum_of each.unsatisfied_consumption) to: uc;
		add (households mean_of each.emotional_state) to: avg_es;
		
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
	monitor "avg Qtime" value: households mean_of each.queuing_time;
	monitor "unsatisfied consumption" value: households sum_of each.unsatisfied_consumption;
	
	monitor "average serving size" value: (facilities sum_of each.food_served) / (facilities sum_of each.nb_served);
		
	}
}


experiment batch_experiment type: batch keep_seed: true repeat: 4 until: (cycle>(30*cycles_in_day)){
	
	parameter "alpha" var: alpha min: 0.1 max: 0.1 step: 0.01;
	parameter "beta" var: beta min:0.5 max: 0.5 step: 0.5;
 	parameter "gamma" var: gamma min:5 max: 5 step: 25;
 	parameter "epsilon" var: epsilon min: 0.8 max: 0.8 step: 0.7; 

 	
 	parameter "avg_interactions" var: avg_interactions min: 3 max: 3 step: 5;

 	parameter "Est. facility capacity per cycle" var: parallel_served_full min: 2 max:7 step: 5;
	
	int sim <-63;
	
	reflex t {
		
		ask simulations {
			
			// add line with the corresponding input parameters
			string outcome <- string(alpha) + ","+beta+","+gamma+","+epsilon+","+avg_interactions+","+parallel_served_full+"\n0.0";
			
			// avg_es
			loop v over: avg_es{
				outcome <- outcome + ","+v;
			}
			outcome<-outcome+"\n0.0";
			
			//uc
			loop v over: uc{
				outcome <- outcome + ","+v;
			}
			outcome<-outcome+"\n0.0";
			
			// avg_ds
			loop v over: avg_ds{
				outcome <- outcome + ","+v;
			}
			outcome<-outcome+"\n0.0";
			// avg_qs
			loop v over: avg_qs{
				outcome <- outcome + ","+v;
			}
			outcome<-outcome+"\n";
			
			save outcome to: "/home/daan/GAMA/workspace/results/scaling_2k/sim"+myself.sim+".csv" type: "csv";
			myself.sim<-myself.sim+1;
		}
	}
}















