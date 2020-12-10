/**
* Name: householdsmodel
* File with definition of households species 
* Author: daan
* Tags: 
*/


model households_model


//import "facilities_model.gaml"
import "households_test.gaml"
//import "DEVS_sim.gaml"



species households skills:[moving] {
	
//	Visual parameters
	rgb color <- #green;
		
//	Constants
	float ration;
	point home_location;
	float infected_threshold;
//	facilities my_facility; 
	
//	Specific constants
	int nb_members; 
	float pc; 
	list<households> social_network;
		
//	Routing variables
	bool incentive_to_facility;
	bool incentive_to_home;
//	facilities facility_of_choice;
		
//	Variables 
	float food_demanded;
	float food_storage;
	float emotional_state;
	int emotional_timestamp;
	
//	Statistics
	float unsatisfied_demand;
	float unsatisfied_consumption;
	
	
	
//	Function to visualise
	aspect map_visualisation {	
		draw circle(7.5#m) color: color; 
	}
	
// Actions	

	action consider_going_to_facility {		
		int opening_hour <- 8;
		int closing_hour <- 20; 
		int active_hours <- closing_hour-opening_hour;
		
		float probability_of_going <- 0.0;
		
		if opening_hour <= current_date.hour and current_date.hour < closing_hour {
			probability_of_going <- 1/(active_hours*cycles_in_hour);
		}
		
		if (rnd(0,100)/100) < probability_of_going{
			
			write name + " goes at "+current_date;
			
			float demand <- determine_demand();
			
			// Temporary statistic to evaluate shit
			unsatisfied_demand <- unsatisfied_demand + demand; 
			
		}
		
	}

	action consume_food { 													// Function consuming food/being hungry			
		if food_storage < nb_members * ration/30 {					// if foood storage is smaller than amount needed
			unsatisfied_demand <- unsatisfied_demand + (nb_members*ration/30 - food_storage);
			food_storage<-0.0; 											
				
		} else {															// if food storage is sufficient
			food_storage <- food_storage - nb_members * ration/30; 	// update food storage minus consumption 
			}
		}
		
	float determine_demand { 								// Returns the demand based on randomness  
		return  gamma * ration/30 * nb_members; 			// rnd(days) * daily food cons * nb of hh members 
		}
	
	
//	facilities determine_facility { 							// Function determining closes faculty 	
//		float min_dist <- #infinity; 							// infinitely large minimal distance
//		facilities closest_fac <- nil; 							// no closest facility 
//		loop fac over: facilities { 							// loop over all facilities in system 
//			if distance_to(location,fac.location)<min_dist and fac != facility_of_choice{ 	// if distance between facilities is smaller than before
//				min_dist <- distance_to(location,fac.location); // update smallest distance
//				closest_fac <- fac; 							// update facility 
//				}
//			}
//		return closest_fac; 
//		}
	
//	action enter_queue{								// Function arranging entering queue 
//		if facility_of_choice.queue_open = true{	// if the facility's queue is open 
//			ask facility_of_choice {				// ask facility to 
//				add myself to: queue;				// add this household agent to queue 
//			}			
//		} 		
//	}

	action forget{
		emotional_state <- emotional_state / (1+(current_date.day-emotional_timestamp)*alpha);
	}

//
//	action go_facility{								// Function sending to facility
//		do goto(facility_of_choice) speed: speed;	// go to facility with speed
//	}
	
	action go_home {								// Function sending to home
		do goto(home_location) speed: speed;		// go to home with speed
		}


	action socialise {		
//		Set boundaries for time-based social interaction: between wake_up and go_sleep, social interaction
		int wake_up <- 6;
		int go_sleep <- 23; 
		float daily_probability_of_interaction <- emotional_state*beta;		
		int active_hours <- go_sleep - wake_up;	
		
//		Set standard probability when being outside of active hours
		float probability_of_interaction <- 0.0;
		
//		Change probability when the current hour is within active hours
		if wake_up<=current_date.hour and current_date.hour<go_sleep {
			float probability_of_interaction <- daily_probability_of_interaction / (active_hours * cycles_in_hour);
		}
		
//		For every befriended household in the social network, with a p_of_interaction the emotional state is updated
		loop friend over: social_network {	
			if (rnd(0,100)/100) <  probability_of_interaction {							
				float new_emotional_state <- pc * (1-(1-friend.emotional_state)*(1-emotional_state)) + (1-pc)*emotional_state*friend.emotional_state;
				ask friend {
					self.emotional_state <- self.pc * (1-(1-self.emotional_state)*(1-myself.emotional_state)) + (1-self.pc)*self.emotional_state*myself.emotional_state;
				}
				emotional_state <- new_emotional_state;
			}
		}
	}


//	Reflexes

	reflex live {
				
//		At the beginning of each day 1) consume food and 2) determine whether the agent wants to go to a facility
		if current_date.hour = 0  and current_date.minute = 0{
			do consume_food;		
			if (food_storage < gamma * ration/30 * nb_members) {
				incentive_to_facility <- true;
			}
			do forget;
		}
		
		if emotional_state > infected_threshold {
			do socialise;
		}
		
		if incentive_to_facility {
			
			do consider_going_to_facility;
		}
		
		
		
//		Add the logic for WHEN to demand for food
		
	}
	

	
}