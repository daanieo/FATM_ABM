/**
* Name: facilitiesmodel
* Definition of facilities species 
* Author: daan
* Tags: 
*/


model facilitiesmodel

import "households_model.gaml"
import "DEVS_sim.gaml"

species facilities{
//	Visual parameters
	float size <- 100 #m;
	rgb color <- #blue;
	
//	Constants
	float facility_food_storage_size;
	int nb_beneficiaries;
	
//	States
	bool queue_open; 
	
//	Variables 
	list<households> queue;
	float facility_food_storage;
	
//	Function to visualise
	aspect map_visualisation {		
		draw square(size) color: color ;
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
		
		

	action satisfy_demand (households HH ) {  								// Updates food storage in households and facility  
		ask HH {
			self.food_storage <- self.food_storage + self.food_demanded; 	// update food storage in household agent
			incentive_to_home <- true;										// send beneficiary home 
			

		}
		
		facility_food_storage <- facility_food_storage - HH.food_demanded;	// update food storage in facility agent 
		
	}
	
	

	
	
	
	
//	Reflexes
	reflex check_queue {  
		
		if length(queue)>0 {
			
			loop times: served_parallel { 	// serves capacity_per_cycle people per cycle
				
				if length(queue)=0{ 			// stops if the queue is empty
					break;
				} else{
					
					float food_demanded <- first(queue).food_demanded;
					do satisfy_demand(first(queue)); 
					remove first(queue) from: queue;
					
				}				
			}
			}
		}
		
	reflex refill { // Daily refill 
		if cycle mod cycles_in_day = 0{ 		// every day 
			facility_food_storage <-  facility_food_storage_size * avg_nb_building; 	// refill storage up to max capacity
			queue_open <- true;					// (re-)open queue
		}
	}	
		
			
	}