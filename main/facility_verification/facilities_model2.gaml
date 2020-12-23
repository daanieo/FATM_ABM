/**
* Name: facilitiesmodel
* Definition of facilities species 
* Author: daan
* Tags: 
*/


model facilitiesmodel2

import "households_model2.gaml"
import "QReaction_test.gaml"

species facilities{
//	Visual parameters
	float size <- 100 #m;
	rgb color <- #blue;
	
//	Constants
	float facility_food_storage_size;
	int nb_beneficiaries;
	int parallel_served;
	
//	States
	bool queue_open; 
	
//	Variables 
	list<households> queue;
	float facility_food_storage;
	
	int nb_served<-1; 
	float food_served;
	
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
		
		


	
	
	
//	Reflexes
	reflex check_queue {  
		
		
		if current_date.hour = 0  and current_date.minute = 0{ 		// every day 
			facility_food_storage <- 15*nb_households; 	// refill storage up to max capacity
			queue_open <- true;					// (re-)open queue
		}
		
		if length(queue)>0 {
			
			if opening_hour <= current_date.hour and current_date.hour < closing_hour {
			
				loop times: parallel_served { 	// serves capacity_per_cycle people per cycle
					
					if length(queue)=0{ 			// stops if the queue is empty
						break;
					} else{
											
						float food_demanded <- first(queue).determine_demand();
						
						float granted <- food_demanded;			
						
						facility_food_storage <- facility_food_storage - granted;
						
						ask first(queue) {
							food_storage <- food_storage + granted;
							unsatisfied_demand <- unsatisfied_demand + food_demanded-granted;
						}
						nb_served <- nb_served +1;
						food_served<-food_served+granted;
						remove first(queue) from: queue;
						
					}				
				}
				} else {
					loop while: length(queue)>0{
						ask first(queue) {
							unsatisfied_demand <- unsatisfied_demand + determine_demand();
						}
						remove first(queue) from: queue;
					}
				}
				
				
			}
		}
		

			
	}