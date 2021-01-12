/**
* Name: householdsmodel
* File with definition of households species 
* Author: daan
* Tags: 
*/


model households_model2


import "facilities_model2.gaml"
import "mechanical_model.gaml"



species households skills:[moving] {
	
//	Visual parameters
	rgb color <- #green;
	float speed<- 4 / 3.6; 
		
//	Constants
	float ration;
	point home_location;
	float infected_threshold;
	facilities my_facility; 
	
//	Specific constants
	float remaining_ration;
	int nb_members; 
	float pc; 
	list<households> social_network;
	int identity_number;
	
		
//	Routing variables
	bool incentive_to_facility;
	bool incentive_to_home;
	facilities facility_of_choice;
		
//	Variables 
	float food_storage;
	float emotional_state;
	int emotional_timestamp;
	date queue_timestamp;
	float unsatisfied_consumption;
	float degraded_food;
	
	
//	Statistics
	list<float> uc; // unsatisfied consumption
	list<float> es; // emotional state
	list<float> fs_p; // food storage per person
	
	float distance_covered;
	
//	Function to visualise
	aspect map_visualisation {	
		draw circle(7.5#m) color: color; 
	}
	
// Actions	


//	Consider going to facility based on time, spread out the demand optimally
	action consider_going_to_facility {		

		int active_hours <- closing_hour-wake_up;
		
		float probability_of_going <- 0.0;
		
		if wake_up <= current_date.hour and current_date.hour < closing_hour and remaining_ration>0{
			probability_of_going <- 1/(active_hours*cycles_in_hour);
		}
		
		if access_policy=2 {
			if mod(current_date.day,6) = identity_number{
				if (rnd(0,100)/100) < probability_of_going{
					incentive_to_facility <- true;			
				}
			}
		} else {
			if (rnd(0,100)/100) < probability_of_going{
				incentive_to_facility <- true;			
			}
		}			

		
	}

	action consume_food { 													// Function consuming food/being hungry			
		if food_storage < (nb_members * ration/30) {					// if foood storage is smaller than amount needed
			
			unsatisfied_consumption <- unsatisfied_consumption + (nb_members*ration/30 - food_storage);
			food_storage<-0.0; 		
										
				
		} else {															// if food storage is sufficient
			food_storage <- food_storage - nb_members * ration/30; 	// update food storage minus consumption 
			}
		}
		
	float determine_demand { 								// Returns the demand based on being infected or not
		
		float policy_influenced_gamma <- gamma;
		
		if access_policy = 1 or access_policy = 2{
			policy_influenced_gamma <- 7.0;
		}
						
		if emotional_state>=infected_threshold {
	
			return min(ration*emotional_state*nb_members,remaining_ration);
		} else{
			
			return  min(policy_influenced_gamma * ration/30 * nb_members,remaining_ration);
		}		
		}
	
	
	facilities determine_facility { 							// Function determining closes facility except for current facility
		float min_dist <- #infinity; 							// infinitely large minimal distance
		facilities closest_fac <- nil; 							// no closest facility 
		loop fac over: facilities { 
	
										// loop over all facilities in system 
			if distance_to(location,fac.location)<min_dist and fac != facility_of_choice{ 	// if distance between facilities is smaller than before
				min_dist <- distance_to(location,fac.location); // update smallest distance
				closest_fac <- fac; 							// update facility 
				}		
				
			}
		return closest_fac; 
		}
	
	action enter_queue{								// Function arranging entering queue 
		
		if facility_of_choice.queue_open = true{	// if the facility's queue is open 
			do perceive_queue(length(facility_of_choice.queue));
			queue_timestamp <- current_date;
			ask facility_of_choice {				// ask facility to 
				add myself to: queue;				// add this household agent to queue 
			}			
			incentive_to_facility <- false;
		} else {
			
			do reroute; // determine where to go if the facility's queue is closed
	
		} 		
	}

	action forget{
		float forgettingfactor <- (current_date.day-emotional_timestamp)*(alpha/cycles_in_day);
		emotional_state <- emotional_state / (1+forgettingfactor);
	}


//	Send the agent to the preferred facility
	action go_facility{								// Function sending to facility
		distance_covered <- distance_covered + speed / cycles_in_hour;
		do goto(facility_of_choice) speed: speed;	// go to facility with speed
	}
	
//	Sends the agent home
	action go_home {								// Function sending to home
		distance_covered <- distance_covered + speed / cycles_in_hour;
		do goto(home_location) speed: speed;		// go to home with speed
		}

//    Sets the emotional state to 1 when a queue is too long
	action perceive_queue(int length_of_queue) {
//		Determine the tolerance for the length of a queue
		int active_hours <- closing_hour-opening_hour;
		float tolerance <- epsilon*(1-pc)*active_hours*parallel_served*cycles_in_hour;
//		If the queue is perceived to be too long
		if length_of_queue > tolerance {	
			emotional_state <- max(emotional_state,pc);
		}	
	}
	
	action reroute {
		//rerouting_policies <- ["base","rr1","rr2"];
		
		if rerouting_policy=0 {
			incentive_to_facility<-false;
			incentive_to_home<-true;	
			emotional_state <- max(emotional_state,pc);
		}
		
		if rerouting_policy=1 {
			if facility_of_choice != my_facility{
				incentive_to_facility<-false;
				incentive_to_home<-true;
				emotional_state <- max(emotional_state,pc);
			} else {
				facility_of_choice <- one_of(facilities);
			}
			
		}
		
		if rerouting_policy=2 {
			
			if facility_of_choice != my_facility{
				incentive_to_facility<-false;
				incentive_to_home<-true;
				emotional_state<-max(emotional_state,pc);
			} else {
				facility_of_choice<-determine_facility();
			}
			
		}

		
	}

	action socialise {		
//		Set boundaries for time-based social interaction: between wake_up and go_sleep, social interaction
		float daily_probability_of_interaction <- emotional_state*beta;		
		int active_hours <- go_sleep - wake_up;	
		
//		Set standard probability when being outside of active hours
		float probability_of_interaction <- 0.0;
		
//		Change probability when the current hour is within active hours
		if wake_up<=current_date.hour and current_date.hour<go_sleep {
			probability_of_interaction <- daily_probability_of_interaction / (active_hours * cycles_in_hour);
		}
		
//		For every befriended household in the social network, with a p_of_interaction the emotional state is updated
		//loop friend over: social_network {	
		loop times: avg_interactions {
			households friend <- one_of(households);
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
				
//		At the beginning of each day 1) consume food and 2) determine whether the agent wants to go to a facility
		if current_date.hour = 0  and current_date.minute = 0{
			// statistics
//			add unsatisfied_consumption to: uc;
//			add emotional_state to: es;
//			add food_storage/nb_members to: fs_p;
						
			do consume_food;		
			do forget;
			
			facility_of_choice<-my_facility;
		}
		
//		If the agent is 'infected' with anxiety
		if emotional_state >= infected_threshold{
			do socialise;
			do consider_going_to_facility;
		}
		
//		Consider going to a facility when home
		if (food_storage < gamma * ration/30 * nb_members) and self.location = home_location{
			do consider_going_to_facility;
		}		
		
//		If there's an incentive to go to a facility
		if incentive_to_facility{
//			If not at facility
			if self.location != facility_of_choice.location {
				do go_facility;
//			If at facility
			} else {
				do enter_queue;
			}			
		}
		
//		If there's an incentive to go home
		if incentive_to_home{
//			If not home
			if self.location != home_location{
				do go_home;
//			If home
			} else {
				incentive_to_home <- false;
			}
		}
	
	
		
	}
	

	

	
}