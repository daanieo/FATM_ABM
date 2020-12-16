/**
* Name: Zone02_simulation
* Based on the internal empty template. 
* Author: daan
* Tags: 
*/


model facilities_test

import "facilities_model.gaml"
import "households_model.gaml"


global {

//	Experiment-variable and potential vital variable
	int avg_hh_size<-5;
	int parallel_served<-10;
	int nb_households <- 2500;
		
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
	float epsilon; // Not relevant 
	

	init {

//		Create facility agents
		create facilities number: 1 { //from: faccoordinates with: [facility_food_storage_size::read('Size')] { 
									
			// Assign empties to variables 
			nb_beneficiaries <- 0; 
			queue <- [];
			queue_open<-true;
			facility_food_storage <- 2500*15; // At initialisation, food storage has max capacity 
			
			nb_served <-1;

		}
		
//		Create household agents
		create households number: nb_households{
			
//			Constants
			ration <- 15.0; 				// kg rice / pers / day
			infected_threshold <- 0.5;
//			home_location <- any;				// home location = current location 
			
//			Specific constants
			nb_members <- rnd(1,avg_hh_size*2+1);
			pc<- 0.5;//rnd(0,10)/10;		
			
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
 	parameter "Est. facility capacity per cycle" var: parallel_served min: 1 max:100 step: 1;
 	parameter "gamma" var: gamma min:1 max: 30 step:1;
	
		
	output {

		
	display data_viz {
       	chart "Facilities food storage" type: series y_label: "kg rice" y_range:[0,20*2500] x_range: [0,20000] size: {0.5,0.5} position: {0.5, 0}{
        data "food storage" value: facilities[0].facility_food_storage;
        

    }    
       	chart "Facilities queue lengths" type: series y_label: "# people" y_range:[0,1000] x_range: [0,20000]size: {1.0,0.5} position: {0, 0.5} {
        loop f over: facilities {
    		data f.name value: length(f.queue);
		}

    }
    
    	chart "summed food storage of household" type: series y_label: "summed food" y_range:[0,2*15/30 * gamma * avg_hh_size * nb_households] x_range: [0,20000] size: {0.5,0.5} position: {0,0} {
    		data "summed food" value: households sum_of each.food_storage;
    	}
	  
	}
	monitor "Queue length" value: length(facilities[0].queue);
	monitor "nb served" value: facilities[0].nb_served;
//	monitor "Total hungry days" value: total_hungry_days;
	}
}

experiment HouseholdsToFacility keep_seed: true type: gui {
	parameter "ParallelServed" var: parallel_served;
	parameter "alpha" var: alpha;
	parameter "beta" var: beta;
	parameter "gamma" var: gamma;
	
	output{
		monitor "tick" value: cycle;
		monitor "AverageDeliverySize" value: float(facilities[0].food_served)/float(facilities[0].nb_served);
		monitor "QueueLength" value: length(facilities[0].queue);
		monitor "FacilityStorage" value: facilities[0].facility_food_storage;
		
	}
}














