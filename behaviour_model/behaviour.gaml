/**
* Name: behaviour
* Based on the internal skeleton template. 
* Author: daan
* Tags: 
*/

model behaviour

global {
	
	float alpha<-0.1; // Forgetting rate
	float beta<-1.0; // Talkativity
	
	list<float> avg_emotional_states;

	
	init {
		
		
		csv_file f <- csv_file("fully_matrix.csv");
		
		matrix sn_matrix <- matrix(f);

		int nb_households <- 5;
		
		create households number: nb_households {
						
//			Constants
			infected_threshold <- 0.5;
			personal_characteristic <- rnd(0,10)/10;
					
//			Variables
			emotional_state <- 0.2;//rnd(0,10)/10;
			timestamp <- 0;
			
			write name+" has pc value of "+personal_characteristic;
			
			add personal_characteristic to: tickwise_emotional_state;
				
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
	
	reflex fetch_stats {
		
		add households mean_of each.emotional_state to: avg_emotional_states;
		
	}
	
	
//	reflex save_result {
//	    save ("cycle: "+ cycle + "; nbPreys: " + nb_preys
//	      + "; minEnergyPreys: " + (prey min_of each.energy)
//	      + "; maxSizePreys: " + (prey max_of each.energy) 
//	      + "; nbPredators: " + nb_predators           
//	      + "; minEnergyPredators: " + (predator min_of each.energy)          
//	      + "; maxSizePredators: " + (predator max_of each.energy)) 
//	      to: "results.txt" type: "text" ;
//}
	

	
}

species households {
	
//	PM consts
	float personal_characteristic; 
	
	float infected_threshold; 
	
//	PM vars -> 1 more anxious
	float emotional_state;
	float timestamp;
		
//	Social relations 
	list<households> social_network; 
	
//	Statistics
	list<float> tickwise_emotional_state;
	
	
	action socialise {
			
		float condition <- emotional_state*beta;

		loop friend over: social_network {
			
			
			if (rnd(0,10)/10) <=  condition {
							
				float new_emotional_state <- personal_characteristic * (1-(1-friend.emotional_state)*(1-emotional_state)) + (1-personal_characteristic)*emotional_state*friend.emotional_state;
				
				ask friend {
					self.emotional_state <- self.personal_characteristic * (1-(1-self.emotional_state)*(1-myself.emotional_state)) + (1-self.personal_characteristic)*self.emotional_state*myself.emotional_state;
				}
				
				emotional_state <- new_emotional_state;
			
			}
			
		}
		
	}
	
	action forget {

		
		emotional_state <- emotional_state / (1+(cycle-timestamp)*alpha);

		
		
	}

	
	reflex live {
		
		do forget;
		
		if name = 'households0' and cycle = 15{
			emotional_state <- 1.0;
			timestamp<-cycle;
		}
		
		if emotional_state > infected_threshold{
			do socialise;
		}
		
		
		

		add emotional_state to: tickwise_emotional_state;

	}
	
	
}



experiment behaviour type: gui {

	parameter 'beta' var: beta min: 0.0 max: 1.0 step: 0.1;
	
	output {
		
	
		
		monitor "emo state 0" value: households[0].emotional_state;
	 	monitor "pc 0" value: households[0].personal_characteristic;
	 	monitor "pc friend0" value: households[0].social_network[0].personal_characteristic;
	 	monitor "pc friend1" value: households[0].social_network[1].personal_characteristic;
	 	
	 	
	 	monitor "nb friends" value: length(households[0].social_network);
		
		
	
		display data_viz {
	       	chart "PM household 0" type: series y_range:[0,1] x_range: [0,100] size: {1,0.5} position: {0, 0}{
	       		
	       	loop hh over: households {
	       		data hh.name value: hh.emotional_state;
	       	}	
	       	
	    }
	    
	    }
	    

	    
	    	    
	    }
	  }
	  		
experiment 'Run 5 simulations' type: batch repeat: 100 keep_seed: false until: ( cycle > 100 ) {
	
    parameter 'beta' var: beta min: 0.0 max: 1.0 step: 0.1;


    reflex t {
    	int runt <- 0;        
		ask simulations {
			
		
			save avg_emotional_states to: "results/avg_es"+runt+"beta"+(beta with_precision 1)+".csv" type:"csv";
			
			save households collect each.tickwise_emotional_state to: "results/result"+"beta"+(beta with_precision 1)+".csv" type: "csv";
			runt<-runt+1;
		}
		
		
    }
}
	
