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
	
//	list<string> capacity_policies <- ["capacitated","uncapacitated","spread"];			// init facilities
//	list<string> minfood_access_policies <- ["base","minfood"]; 						// hh -> determine demand
//	list<string> maxfood_access_policies <- ["base","maxfood","twoweekration"]; 		// hh -> determine demand
//	list<string> day_access_policies <- ["base","tar"]; 								// hh -> consider_facility; init 
//	list<string> rerouting_policies <- ["base_base","base_managed","spread","closest"]; // queue open ; hh -> reroute 
	
//	Model structure
	int capacity_policy <- 0;
	int minfood_access_policy <- 0;
	int ration_size_policy <- 30;
	int day_access_policy <- 0; 
	int rerouting_policy <- 0; 

	bool extended_service <- false;	
	bool breakdown_scenario <- false;
	int broken_facility_id <- 8;
	
	file shape_file_buildings <- shape_file("/home/daan/Documents/input_files/building_polygons/filtered/2217.shp","EPSG:4326");
//	file shape_file_buildings <- shape_file("/home/daan/Documents/input_files/building_polygons/filtered/3022.shp","EPSG:4326");
//	file shape_file_buildings <- shape_file("/home/daan/Documents/input_files/building_polygons/filtered/6650.shp","EPSG:4326");
//	file shape_file_buildings <- shape_file("/home/daan/Documents/input_files/building_polygons/filtered/33249.shp","EPSG:4326");

	file shape_file_facilities <- shape_file("/home/daan/Documents/FATM_opt/save_files/gdf_0f/gdf_0f.shp","EPSG:4326"); // for everything functional
	
	geometry shape <-envelope(shape_file_buildings);
	
//	int scaling_factor <- 11; 
//	int scaling_factor <- 5;
//	int scaling_factor <- 1;

//	Experiment-variable and potential vital variable
	int scaling_factor <- 15;
	int default_nb_households <- 2500;
	int nb_households <- round(default_nb_households/scaling_factor);
	int avg_hh_size<-7;

	float parallel_served_full <- 3.0;
	float parallel_served <- parallel_served_full/scaling_factor;

	int avg_interactions <- 5;
		
	float alpha <- 0.5;
	float beta <- 0.5;
	float gamma <- 7.0;
	float epsilon <- 0.5;  
	
	
	float avg_food_consumption <- 0.5; // food consumption per person per day
	int food_preservation_days <- 14; // the number of days 
	float avg_degradation_portion <- 1.0; // the average portion of food subject to degradation that actually rots
		
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
		create facilities from: shape_file_facilities with: [nb_beneficiaries::read ("size"), facility_id::read("fatm_id")] { 
									
//			Assign empties to variables 
			queue <- [];
			queue_open<-true;
			facility_food_storage_size <- nb_beneficiaries*15/scaling_factor;
			facility_food_storage <- facility_food_storage_size; //nb_households*15/scaling_factor; // At initialisation, food storage has max capacity 
			
//			Initialise statistics
			food_served <- 0.0;
			nb_served <-0;
			
		}
		
//		Create household agents
		create households from: shape_file_buildings{

//			Policy-dependent variables			
			ration <- ration_size_policy*avg_food_consumption;
			
			if capacity_policy = 2 {
				my_facility <- one_of(facilities);
			} else {
				my_facility <- determine_facility();	// home facility is current closest facility 
			}
			
			
//			Constants
			infected_threshold <- 0.5;				// threshold to changing the agent to be "infected"
			home_location <- location;				// home location = current location 
			speed <- 4/3.6;					// speed of beneficiaries 
			social_network <- [];
			
			identity_number <- rnd(0,2); // when to go to facility
	
//			Unique constants
			nb_members <- rnd(avg_hh_size-3,avg_hh_size+3); // houshold size equally varying between 4 and 10 
			pc<- rnd(0,100*epsilon)/100; 						// personal characteristic varying between 0 and 1
			home_location <- location;				// home location = current location 
			
//			my_facility.nb_beneficiaries <- my_facility.nb_beneficiaries + 1;
			
//			Variables
			remaining_ration<-ration*nb_members;
			
			if day_access_policy = 1 {
				food_storage <- avg_food_consumption * nb_members + identity_number*nb_members*avg_food_consumption;			// initial food storage 
			} else {
				food_storage <- avg_food_consumption * nb_members * (gamma + rnd(0,gamma));			// initial food storage 
			}
			
			emotional_state <- 0.0;
			emotional_timestamp <- 0;
			facility_of_choice <- my_facility;	// initally facility of choice is my facility 
			
//			States			
			incentive_to_facility <- false;
			incentive_to_home <- false;
				
//			Initialise statistics	
			degraded_food <- 0.0;
			unsatisfied_consumption <- 0.0;
			time_queued <- 0.0;
			distance_covered <- 0.0;
			food_consumed <- 0.0;
			

		
		} 
	}
	
	reflex t {
//		
//		add (households sum_of each.unsatisfied_consumption) to: sum_uc;
//		add (households mean_of each.emotional_state) to: avg_es;
//		add (households sum_of each.degraded_food) to: sum_fd;
		
	}
	

	
}





experiment simple_simulation keep_seed: true type: gui   until: (cycle>4320){
	
//	Model structure
	parameter "capacity policies" var: capacity_policy min: 0 max: 1 step: 1; 
	parameter "min food policies" var: minfood_access_policy min: 0 max: 1 step: 1; 
	parameter "max food policies" var: ration_size_policy min: 15 max: 30 step: 15;
	parameter "day access policies" var: day_access_policy min: 0 max: 0 step: 1; 
	parameter "rerouting policies" var: rerouting_policy min: 0 max: 2 step: 1; 
	
	parameter "extended service hours" var: extended_service <- false;
	parameter "breakdown scenario" var: breakdown_scenario <- false;
	parameter "id of broken facility" var: broken_facility_id <- 8; 
	
//	Constants
 	parameter "avg_interactions" var: avg_interactions <- 5; 
 	parameter "Est. facility capacity per cycle" var: parallel_served_full <- (2500 * 10) / 2160;
		
//	Behavioural parameters	
	parameter "alpha" var: alpha min: 0.0 max: 1.0 step: 1.0; // 2
	parameter "beta" var: beta min:0.0 max: 1.0 step: 1; // 2
 	parameter "gamma" var: gamma min:3.0 max: 14.0 step: 11.0; // 2
 	parameter "epsilon" var: epsilon min: 0.0 max: 1.0 step: 1.0; //2 
		
	output {

    display main_display {
        species households ;
        species facilities aspect: map_visualisation ;
    }
	
	
//	Graphs for household agents	
	display beneficiaries {
       	chart "avg es" type: series y_label: "kg rice" y_range:[-0.1,1] x_range: [cycle-1000,cycle+1000] size: {1.0,0.5} position: {0, 0}{
        data "average emotional state" value: households mean_of each.emotional_state;
    }    
    	chart "summed food storage of household" type: series y_label: "summed food" y_range:[0,315000] x_range: [cycle-1000,cycle+1000] size: {1.0,0.5} position: {0,0.5} {
    		data "summed food" value: households sum_of each.food_storage;
    	}
	}
	
//	Graphs for facility agents
	display facilities {
       	chart "Facilities queue lengths" type: series y_label: "# people" y_range:[0,2500] x_range: [cycle-1000,cycle+1000] size: {1.0,1} position: {0, 0} {
        loop f over: facilities {
    		data f.name value: length(f.queue);
		}
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
	
	monitor "Food served 0" value: facilities[0].food_served;
	monitor "Food served 1" value: facilities[1].food_served;
	monitor "Food served 2" value: facilities[2].food_served;
	monitor "Food served 3" value: facilities[3].food_served;
	monitor "Food served 4" value: facilities[4].food_served;
	monitor "Food served 5" value: facilities[5].food_served;
	monitor "Food served 6" value: facilities[6].food_served;
	monitor "Food served 7" value: facilities[7].food_served;
	monitor "Food served 8" value: facilities[8].food_served;
	monitor "Food served 9" value: facilities[9].food_served;
	monitor "Food served 10" value: facilities[10].food_served;
	monitor "Food served 11" value: facilities[11].food_served;


	
//	monitor "avg es" value: households mean_of each.emotional_state;
	monitor "unsatisfied consumption" value: households sum_of each.unsatisfied_consumption;
	monitor "distance covered" value: households sum_of each.distance_covered;  
	monitor "food degraded" value: households sum_of each.degraded_food;
	monitor "food consumed" value: households sum_of each.food_consumed;
		
	}
}

//
//experiment batch_experiment type: batch keep_seed: true repeat: 4 until: (cycle>(30*cycles_in_day)){
//	
//	
////	Model structure
//	parameter "capacity policies" var: capacity_policy min: 0 max: 0 step: 1; 
//	parameter "min food policies" var: minfood_access_policy min: 0 max: 0 step: 1; 
//	parameter "max food policies" var: maxfood_access_policy min: 0 max: 0 step: 1;
//	parameter "day access policies" var: day_access_policy min: 0 max: 0 step: 1; 
//	parameter "rerouting policies" var: rerouting_policy min: 0 max: 2 step: 1; 
//	
//	parameter "extended service hours" var: extended_service <- false;
//	parameter "breakdown scenario" var: breakdown_scenario <- false;
//	parameter "id of broken facility" var: broken_facility_id <- 8; 
//	
////	Constants
// 	parameter "avg_interactions" var: avg_interactions <- 5; 
// 	parameter "Est. facility capacity per cycle" var: parallel_served_full <- (2500 * 10) / 2160;
//		
////	Behavioural parameters	
////	parameter "alpha" var: alpha min: 0.0 max: 1.0 step: 1.0; // 2
////	parameter "beta" var: beta min:0.0 max: 1.0 step: 1.0; // 2
//// 	parameter "gamma" var: gamma min:3.0 max: 14.0 step: 11.0; // 2
//// 	parameter "epsilon" var: epsilon min: 0.0 max: 1.0 step: 1.0; //2 
// 	
//	parameter "alpha" var: alpha min: 0.5 max: 0.5 step: 1.0; // 2
//	parameter "beta" var: beta min:0.5 max: 0.5 step: 1.0; // 2
// 	parameter "gamma" var: gamma min:7.0 max: 7.0 step: 11.0; // 2
// 	parameter "epsilon" var: epsilon min: 0.5 max: 0.5 step: 1.0; //2 
// 	
//
//	int sim <-0;
//		
//	reflex t {
//			
//		int rep<-0;
//		
//		ask simulations {
//			
//			
//			string experiment_name <- 	capacity_policies[capacity_policy]+"_"
//										+minfood_access_policies[minfood_access_policy]+"_"
//										+maxfood_access_policies[maxfood_access_policy]+"_"
//										+day_access_policies[day_access_policy]+"_"
//										+rerouting_policies[rerouting_policy];
//			
//
//			string outcomes_input <- "";
//			string outcomes_sum_fd <- "";
//			string outcomes_avg_es <- "";
//			string outcomes_sum_uc<- "";
//			string outcomes_ql <- "";
//			
//			string outcomes_distance_per_agent <- "";
//			
//			loop v over: households{
//				outcomes_distance_per_agent <- outcomes_distance_per_agent + ","+ v.home_location.x+","+v.home_location.y+","+v.distance_covered;
//			}
//			outcomes_distance_per_agent<-outcomes_distance_per_agent+"\n";
//						
//			outcomes_input <- outcomes_input + rep + "," + alpha + ","+beta+","+gamma+","+epsilon+","+"\n";
//			
////			Add the average emotional state to the outcome string 
//			loop v over: avg_es{
//				outcomes_avg_es <- outcomes_avg_es + ","+v;
//			}
//			outcomes_avg_es<-outcomes_avg_es+"\n";
//	
////			Add the unsatisfied consumption to the outcome string 
//			loop v over: sum_uc{
//				outcomes_sum_uc <- outcomes_sum_uc + ","+v;
//			}
//			outcomes_sum_uc<-outcomes_sum_uc+"\n";		
//			
////			Add the food degradation to the outcome string 
//			loop v over: sum_fd{
//				outcomes_sum_fd <- outcomes_sum_fd + ","+v;
//			}
//			outcomes_sum_fd<-outcomes_sum_fd+"\n";		
//			
////			Add queue lengths to outcome string
//			loop f over: facilities{
//				outcomes_ql <- outcomes_ql + rep + "," + f.name;
//				loop v over: f.length_of_queue{
//					outcomes_ql <- outcomes_ql + "," + v;
//				}
//				outcomes_ql <- outcomes_ql + "\n"; 
//			}
//			
////			save outcomes_input to: "/home/daan/GAMA/workspace/results/"+experiment_name+"/outcomes_input_sim"+myself.sim+"_rep"+rep+".csv" type: "csv";
////			save outcomes_avg_es to: "/home/daan/GAMA/workspace/results/"+experiment_name+"/outcomes_avg_es_sim"+myself.sim+"_rep"+rep+".csv" type: "csv";
////			save outcomes_sum_uc to: "/home/daan/GAMA/workspace/results/"+experiment_name+"/outcomes_sum_uc_sim"+myself.sim+"_rep"+rep+".csv" type: "csv";
////			save outcomes_sum_fd to: "/home/daan/GAMA/workspace/results/"+experiment_name+"/outcomes_sum_fd_sim"+myself.sim+"_rep"+rep+".csv" type: "csv";
////			
////			// Individual facility
////			save outcomes_ql to: "/home/daan/GAMA/workspace/results/"+experiment_name+"/outcomes_ql_sim"+myself.sim+"_rep"+rep+".csv" type: "csv";
////			// Individual agent
//			save outcomes_distance_per_agent to: "/home/daan/Desktop/outcomes_dist_sim"+myself.sim+"_rep"+rep+".csv" type: "csv";
//							
//			rep<-rep+1;
//		}
//
//		sim<-sim+1;
//
//	}
//}


//
//experiment household_stats type: batch keep_seed: true repeat: 4 until: (cycle>(30*cycles_in_day)){
//	
//	
////	Model structure
//	parameter "capacity policies" var: capacity_policy <- 0; 
//	parameter "min food policies" var: minfood_access_policy <- 0; 
//	parameter "max food policies" var: maxfood_access_policy <- 0; 
//	parameter "day access policies" var: day_access_policy <- 0;  
//	parameter "rerouting policies" var: rerouting_policy <- 0;  
//	
//	parameter "extended service hours" var: extended_service <- false;
//	parameter "breakdown scenario" var: breakdown_scenario <- false;
//	parameter "id of broken facility" var: broken_facility_id <- 8; 
//	
////	Constants
// 	parameter "avg_interactions" var: avg_interactions <- 5; 
// 	parameter "Est. facility capacity per cycle" var: parallel_served_full <- (2500 * 10) / 2160;
//			
//	parameter "alpha" var: alpha <- 0.5; 
//	parameter "beta" var: beta <- 0.5; 
// 	parameter "gamma" var: gamma <- 7.0; 
// 	parameter "epsilon" var: epsilon <- 0.5;  
// 	
//
//	int sim <-0;
//		
//	reflex t {
//			
//		int rep<-0;
//		
//		ask simulations {
//			
//
//			
//			string outcomes_distance_per_agent <- "";
//			string outcomes_queuing_per_agent <- "";
//			 
//			
//			loop v over: households{
//				outcomes_distance_per_agent <- outcomes_distance_per_agent + v.home_location.x+","+v.home_location.y+","+v.distance_covered+"\n";
//				outcomes_queuing_per_agent <- outcomes_queuing_per_agent + v.home_location.x+","+v.home_location.y+","+v.time_queued+"\n";
//				
//			}
//						
////			outcomes_input <- outcomes_input + rep + "," + alpha + ","+beta+","+gamma+","+epsilon+","+"\n";
//					
//			save outcomes_distance_per_agent to: "/home/daan/Desktop/outcomes_dist_sim"+myself.sim+"_rep"+rep+".csv" type: "csv";
//			save outcomes_queuing_per_agent to: "/home/daan/Desktop/outcomes_queuetime_sim"+myself.sim+"_rep"+rep+".csv" type: "csv";
//							
//			rep<-rep+1;
//		}
//
//		sim<-sim+1;
//
//	}
//}













