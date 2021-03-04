/**
* Name: facilitiesmodel
* Definition of facilities species 
* Author: daan
* Tags: 
*/


model facilitiesmodel2

import "households_model2.gaml"
import "mechanical_model.gaml"

species facilities{
//	Visual parameters
	float size <- 100 #m;
	rgb color <- #blue;
	
//	Constants
	float facility_food_storage_size;
	int nb_beneficiaries;
	int facility_id;	
	
//	States
	bool queue_open; 
	
//	Variables 
	list<households> queue;
	float facility_food_storage;

//  Statistics	
	int nb_served<-1; 
	float food_served;
	list<float> length_of_queue;
	
	
//	Function to visualise
	aspect map_visualisation {		
		draw circle(100) color: color ;
	}
	
	
//	Actions
	bool check_storage(float demanded_food) {
		return demanded_food<=facility_food_storage;
	}
	
	facilities determine_facility { 							// Function determining closes faculty 	
		float min_dist <- #infinity; 							// infinitely large minimal distance
		facilities closest_fac <- nil; 							// no closest facility 
		loop fac over: facilities { 							// loop over all facilities in system 
			if distance_to(location,fac.location)<min_dist{ 	// if distance between facilities is smaller than before
				min_dist <- distance_to(location,fac.location); // update smallest distance
				closest_fac <- fac; 							// update facility 
				}
			}
		return closest_fac; 
		}
		

	
	
//	Reflexes
	reflex check_queue {  
		
		
		if current_date.hour = 0  and current_date.minute = 0{ 		// every day 
			facility_food_storage <- facility_food_storage_size; 	// refill storage up to max capacity
			queue_open <- true;					// (re-)open queue
		}
		
//		If there's someone queueing
		if length(queue)>0 {
						
//			If the cycle is within opening hours
			if (opening_hour <= current_date.hour and current_date.hour <= closing_hour) or  (opening_hour <= current_date.hour and extended_service){

//				Determine the probability of being served based on facility's capacity			
				float served_this_tick <- round(parallel_served);				
				if capacity_policy=1 { // capacity policy 1 means uncapacitated
					served_this_tick <- round(parallel_served* (nb_beneficiaries/(2500.0 / scaling_factor)) );
					if rnd(10)/10 < (parallel_served* (nb_beneficiaries/(2500.0 / scaling_factor)) - served_this_tick){
						served_this_tick <- served_this_tick + 1;
					}					
				} else {
					if rnd(10)/10 < (parallel_served - served_this_tick){
						served_this_tick <- served_this_tick + 1;
					}					
				}
				

//				Loop n times, serving people in the queue
				loop times: served_this_tick { 
					
					if length(queue)=0{ 			// stops if the queue is empty
						break;
					} else{
						
//						Determine demand and update facility variables										
						float food_demanded <- first(queue).determine_demand();						
						float granted <- food_demanded;							
						facility_food_storage <- facility_food_storage - granted;
						
//						Update households variables
						ask first(queue) {
							food_storage <- food_storage + granted;
							remaining_ration<-remaining_ration-granted;
							degraded_food <- degraded_food + max([0,granted-(nb_members*ration*14/ration_size_policy)]);
							incentive_to_facility<-false;
							incentive_to_home <- true;
							time_queued <- time_queued + float(current_date - queue_timestamp);
						}
						nb_served <- nb_served +1;
						food_served<-food_served+granted;						
						remove first(queue) from: queue;
					}				
				}
				
//				If the cycles is outside opening hours
				} if current_date.hour > closing_hour {
					loop while: length(queue)>0{
						
						ask first(queue) {
							emotional_state <- 1.0;
							incentive_to_facility<-false;
							incentive_to_home <- true;
							time_queued <- time_queued + float(current_date - queue_timestamp);
						}
						remove first(queue) from: queue;
					}
				}
				
//			Make an estimation of the queue's length		
			if (((closing_hour - current_date.hour) * cycles_in_hour * parallel_served) < length(queue)){				
				if rerouting_policy != 0 { // policy options 1,2,3 demand active queue management 
					queue_open<-false;	
				}
			}
			
			// add breakdown scenario
				
			}
		}
	
	

		
	reflex stats {
		add length(queue) to: length_of_queue;
	}
		

			
	}