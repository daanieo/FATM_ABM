/**
* Name: householdsmodel
* File with definition of households species 
* Author: daan
* Tags: 
*/


model households_model


//import "facilities_model.gaml"
import "household_test.gaml"
import "network_test.gaml"
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
	
//	Verification statistics
	list<float> tickwise_emotional_state;
	list<float> tickwise_food_storage;
	
	
	
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
					
			float demand <- determine_demand();
			
			// Temporary statistic to evaluate shit
			unsatisfied_demand <- demand; 
			
			// Update variables
			food_storage <- food_storage + demand;
			incentive_to_facility<-false;
			
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
		
	float determine_demand { 								// Returns the demand based on being infected or not
	
		if emotional_state>=infected_threshold {
			return ration*( gamma * nb_members/30 + emotional_state*(1-gamma*nb_members/30));
		} else{
			return  gamma * ration/30 * nb_members;
		}		
		}
	
	


	action forget{
		emotional_state <- emotional_state / (1+(current_date.day-emotional_timestamp)*(alpha/cycles_in_day));
	}


	
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
			if (rnd(0,10000)/10000) <  probability_of_interaction {							
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
		do forget;
		
		
//		At the beginning of each day 1) consume food and 2) determine whether the agent wants to go to a facility
		if current_date.hour = 0  and current_date.minute = 0{
			do consume_food;		
			if (food_storage < gamma * ration/30 * nb_members) or emotional_state>=infected_threshold{
				incentive_to_facility <- true;
			}
			
		}
		
		if emotional_state > infected_threshold {
			do socialise;
		}
		
		if incentive_to_facility {
			
			do consider_going_to_facility;
		}
	
		
		if name = 'households0' and cycle = 5*24*6 and startle{
			emotional_state <- 1.0;
		}
		
		add emotional_state to: tickwise_emotional_state;
		
//		Add the logic for WHEN to demand for food
		
	}
	

	
}