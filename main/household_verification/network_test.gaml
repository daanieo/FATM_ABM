/**
* Name: Zone02_simulation
* Based on the internal empty template. 
* Author: daan
* Tags: 
*/


model network_test


import "households_model.gaml"
//import "facilities_model.gaml"


global {
	
	
//	Experiment-variable and potential vital variable
	bool startle <- false; 	
	int avg_hh_size<-5;
	float zeta <- 0.5;	
		
//	Time-related constants
	date starting_date <- date("2021-01-01 00:00:00");	
	float step <- 10 #minutes;
	int cycles_in_hour <- 6;
	int cycles_in_day <- 24*6; 
	
//	Vital variables
	float alpha <- 0.1;
	float beta <- 1.0;
	float gamma <-1.0;
	float epsilon; // Not relevant 
	
//	Statistics
	list<float> average_emotional_states;
	list<float> summed_food_storage;
	list<float> summed_demanded_food;
	
	init {
		

		csv_file f <- csv_file("fully_matrix.csv");
		matrix sn_matrix <- matrix(f);
				
		int nb_households<-20;
		
//		Create household agents
		create households number: nb_households{	
	
			// Constants
			ration <- 15.0; 				// kg rice / pers / day
			infected_threshold <- 0.5;
//			home_location <- any;				// home location = current location 
			
//			Specific constants
			nb_members <- rnd(1,avg_hh_size*2+1);
			pc<- rnd(0,10)/10;		
			
			
//			Initialise variables	
			unsatisfied_consumption <- 0.0;
			unsatisfied_demand <- 0.0;
			tickwise_emotional_state <- [];
					
			food_storage <- ration/30 * gamma * nb_members;			// initial food storage 
			emotional_state <- 0;
			emotional_timestamp <- 0;
					
		}
		
//		Making the social network based on the imported sn_matrix		
		loop i from: 0 to: (nb_households-1) {			
			loop j from: 0 to: (nb_households-1) {					
				if int(sn_matrix[i,j]) = 1{			
					ask households[int(i)]{
						add households[j] to: social_network;	
						}
				} else{
				}
			}			
		}
	}
	
	reflex fetch_statistics {
		add households mean_of each.emotional_state to: average_emotional_states;	
		add households sum_of each.food_storage to: summed_food_storage;
		add households sum_of each.unsatisfied_demand to: summed_demanded_food; // unsatisfied demand as temporary container 	 
		
	}
	
}



experiment simple_simulation_network keep_seed: true type: gui {
	parameter "No startle" var: startle <- true;
	parameter "Forgetting rate" var: alpha min: 0 max: 1 step: 0.01;
	parameter "Talkativity" var: beta min: 0 max: 1 step: 0.1; 
	parameter "Security stock size" var: gamma min: 0 max: 30 step: 1; 
	parameter "Average pc" var: zeta min: 0 max: 0.5 step: 0.1; 
	
 
	int nb_days_runtime <- 10;
		
	output {
		
	display emotional_graphs {
       chart "Emotional state of all households" type: series y_label: "emotional state" y_range:[0,1] x_range: [0,nb_days_runtime*cycles_in_day] size: {1.0,0.5} position: {0, 0.5}{
       loop hh over: households {
       		data hh.name value: hh.emotional_state;
        }
		}
       chart "Average emotional state over time" type: series y_label: "emotional state" y_range:[0,1] x_range: [0,nb_days_runtime*cycles_in_day] size: {1.0,0.5} position: {0, 0}{
       data "Avg emo state" value: households mean_of each.emotional_state; 
		}		
	}
	
	display food_graphs {
       chart "Summed demand over time" type: series y_label: "demanded food" y_range:[0,300] x_range: [0,nb_days_runtime*cycles_in_day] size: {1.0,0.5} position: {0, 0}{
       data "sum food" value: households sum_of each.unsatisfied_demand; // unsatisfied demand as temporary container 
		}	
		chart "Summed food storage over time" type: series y_label: "food in storage" y_range:[0,300] x_range: [0,nb_days_runtime*cycles_in_day] size: {1.0,0.5} position: {0, 0.5}{
       data "sum food in storage" value: households sum_of each.food_storage; 
		}	
			
	}
    monitor "average emotional state" value: households mean_of each.emotional_state; 
    monitor "startling?" value: startle;
    
    }
}
    




experiment NetworkStartle type: gui {
	parameter "startle" var: startle <- true;
	parameter "alpha" var: alpha;
	parameter "beta" var: beta;
	parameter "gamma" var: gamma; 
	output{monitor "AverageEmotionalState" value: households mean_of each.emotional_state;
			monitor "tick" value: cycle;
			monitor "EmotionalState" value: households[0].emotional_state;		
		
	}
}






















