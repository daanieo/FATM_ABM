/**
* Name: Zone02_simulation
* Based on the internal empty template. 
* Author: daan
* Tags: 
*/


model Qreaction_test

import "facilities_model.gaml"
import "households_model.gaml"


global {
	
	file households_shp <- shape_file("/home/daan/Documents/input_files/building_polygons/all_zones.shp","EPSG:4326");
	file facilities_shp <- shape_file("/home/daan/Documents/FATM_opt/save_files/gdf_0f/gdf_0f.shp","EPSG:4326");
	geometry shape <-envelope(households_shp);

//	Experiment-variable and potential vital variable
	float avg_hh_size<-3.25;
	int service_capacity <- 5;
	
	int avg_interactions <- 4;
		
//	Time-related constants
	date starting_date <- date("2021-01-01 00:00:00");	
	float step <- 10 #minutes;
	int cycles_in_hour <- 6;
	int cycles_in_day <- 24*6; 
	int opening_hour <- 8;
	int closing_hour <- 20;
	
//	Vital variables
	float alpha <- 0.1;
	float beta <- 1.0;
	float gamma <-10.0;
	float epsilon<-0.0;  
	

	init {

//		Create facility agents
		create facilities from: facilities_shp { //from: faccoordinates with: [facility_food_storage_size::read('Size')] { 
									
			// Assign empties to variables 
			nb_beneficiaries <- 0; 
			queue <- [];
			queue_open<-true;
			facility_food_storage <- 2500*15; // At initialisation, food storage has max capacity 
			
			nb_served <-1;
			
			parallel_served <- service_capacity;

		}
		
//		Create household agents
		create households from: households_shp { //number: nb_households{
			
//			Constants
			ration <- 15.0; 				// kg rice / pers / month
			infected_threshold <- 0.5;
			home_location <- location;				// home location = current location 
			
//			Specific constants
			nb_members <- rnd(1,avg_hh_size*2+1);
			pc<- rnd(0,10)/10;		
			
//			Initialise variables	
			unsatisfied_consumption <- 0.0;
			unsatisfied_demand <- 0.0;
					
			food_storage <- ration/30 * gamma * nb_members + rnd(0,gamma)*nb_members*ration/30;			// initial food storage 
			emotional_state <- 0;
			emotional_timestamp <- 0;
			
			speed <- 4 #km/#hour;					// speed of beneficiaries 
	
			// Constants
			home_location <- location;				// home location = current location 
			my_facility <- determine_facility();	// home facility is current closest facility 
			
			social_network <- [];
			
			// Initial values variables
			facility_of_choice <- my_facility;	// initally facility of choice is my facility 
			
			// add the number of household members to the facility			
			ask my_facility {
				nb_beneficiaries <- nb_beneficiaries + myself.nb_members; 
			}			
		} 
	}
	

	
}



experiment simple_simulation keep_seed: true type: gui {
//	parameter "Shapefile for the buildings:" var: shape_file_buildings category: "GIS" ;
 	parameter "Est. facility capacity per cycle" var: service_capacity min: 1 max:100 step: 1;
 	parameter "gamma" var: gamma min:1 max: 30 step:1;
 	parameter "epsilon" var: epsilon min: 0 max: 1 step: 0.1; 
	
	parameter "alpha" var: alpha min: 0 max: 1 step: 0.01;
	parameter "beta" var: beta min:0 max: 1 step: 0.1;
		
	output {
		
//	display map{
//			species households aspect: map_visualisation;
//			species facilities aspect:map_visualisation;
//		}

		
	display data_viz {
       	chart "avg es" type: series y_label: "kg rice" y_range:[-0.1,1] x_range: [0,4000] size: {0.5,0.5} position: {0.5, 0}{
        data "average emotional state" value: households mean_of each.emotional_state;
        

    }    
       	chart "Facilities queue lengths" type: series y_label: "# people" y_range:[0,2500] x_range: [0,4000]size: {1.0,0.5} position: {0, 0.5} {
        loop f over: facilities {
    		data f.name value: length(f.queue);
		}

    }
    
    	chart "summed food storage of household" type: series y_label: "summed food" y_range:[0,2*15/30 * gamma * avg_hh_size * length(households)] x_range: [0,4000] size: {0.5,0.5} position: {0,0} {
    		data "summed food" value: households sum_of each.food_storage;
    	}
	  
	}
	monitor "Queue length" value: length(facilities[0].queue);
	monitor "nb served" value: facilities[0].nb_served;
	monitor "avg es" value: households mean_of each.emotional_state;
//	monitor "Total hungry days" value: total_hungry_days;
	}
}

experiment FacilityToHouseholds keep_seed: true type: gui repeat:4 {
	
	// 
	parameter "alpha" var: alpha min: 0.1 max: 0.1 step: 0.1;
	parameter "beta" var: beta min:0 max: 1 step: 1;
	parameter "gamma" var: gamma min:5 max: 15 step: 5;
	parameter "epsilon" var: epsilon min:0.2 max: 0.4 step: 0.2;
	
	
	parameter "ParallelServed" var: service_capacity min: 1 max: 10 step: 1;
	parameter "AvgInteractions" var: avg_interactions min: 0 max: 10 step: 1;
	
	output{
		
		monitor "Facility0" value: length(facilities[0].queue);
		monitor "Facility1" value: length(facilities[1].queue);
		monitor "Facility2" value: length(facilities[2].queue);
		monitor "Facility3" value: length(facilities[3].queue);
		monitor "Facility4" value: length(facilities[4].queue);
		monitor "Facility5" value: length(facilities[5].queue);
		monitor "Facility6" value: length(facilities[6].queue);
		monitor "Facility7" value: length(facilities[7].queue);
		monitor "Facility8" value: length(facilities[8].queue);
		monitor "Facility9" value: length(facilities[9].queue);
		monitor "Facility10" value: length(facilities[10].queue);
		monitor "Facility11" value: length(facilities[11].queue);
		
		monitor "tick" value: cycle;
		monitor "AverageEmotionalState" value: households mean_of each.emotional_state;
		monitor "AvgQueueLength" value: facilities mean_of length(each.queue);
		
	}
}

experiment batch_experiment keep_seed: true type: batch repeat:4 until: cycle>30*6*24 {
	
	// 
	parameter "alpha" var: alpha min: 0.1 max: 0.1 step: 0.1;
	parameter "beta" var: beta min:0 max: 1 step: 1;
	parameter "gamma" var: gamma min:5 max: 15 step: 5;
	parameter "epsilon" var: epsilon min:0.2 max: 0.4 step: 0.2;
	
	
	parameter "ParallelServed" var: service_capacity min: 1 max: 10 step: 1;
	parameter "AvgInteractions" var: avg_interactions min: 0 max: 10 step: 1;
	
	output{
		
		monitor "Facility0" value: length(facilities[0].queue);
		monitor "Facility1" value: length(facilities[1].queue);
		monitor "Facility2" value: length(facilities[2].queue);
		monitor "Facility3" value: length(facilities[3].queue);
		monitor "Facility4" value: length(facilities[4].queue);
		monitor "Facility5" value: length(facilities[5].queue);
		monitor "Facility6" value: length(facilities[6].queue);
		monitor "Facility7" value: length(facilities[7].queue);
		monitor "Facility8" value: length(facilities[8].queue);
		monitor "Facility9" value: length(facilities[9].queue);
		monitor "Facility10" value: length(facilities[10].queue);
		monitor "Facility11" value: length(facilities[11].queue);
		
		monitor "tick" value: cycle;
		monitor "AvgQueueLength" value: facilities mean_of length(each.queue);
		
		
	}
}













