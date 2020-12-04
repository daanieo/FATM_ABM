/**
* Name: behaviour
* Based on the internal skeleton template. 
* Author: daan
* Tags: 
*/

model behaviour

global {
	/** Insert the global definitions, variables and actions here */
	
	int rt <- 1;
	int sentiment <- 0;
	
	init {
		
		csv_file f <- csv_file("sn_matrix.csv");
		
		matrix sn_matrix <- matrix(f);

		int nb_households <- 10;
		
		create households number: nb_households {
			v <- 0.5; //rnd(10)/10;
			p <- sentiment; //0.5; //rnd(10)/10;
			mu<- 0.9; //rnd(10)/10;
			
			ei0 <- 0.2;//rnd(10)/10;
			ib0 <- 0.2;//rnd(10)/10;
			rp0 <- 0.2;//rnd(10)/10;
			
			ei<-ei0;
			ib<-ib0;
			rp<-rp0;
			

			
		}
		
//		Making the social network based on the imported sn_matrix		
		loop i from: 0 to: (nb_households-1) {			
			loop j from: 0 to: (nb_households-1) {			
				
				if int(sn_matrix[i,j]) = 1{			
					ask households[int(i)]{
						add households[j] to: SN;	
						}
				} else{
				}
			}			
		}	
		
	}
	
//	reflex save_result when: (nb_preys > 0) and (nb_predators > 0){
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
	float v; // Emotional, -> 1 = fully irrational
	float p; // Optimism, -> 1 = optmistic 
	float mu; // Social, -> 1 = fully socially oriented
	
//	PM vars -> 1 more anxious
	float ei; 
	float ib; 
	float rp; 
	
//	For evaluation
	float ei0;
	float ib0;
	float rp0;

	float dei;
	float dib;
	float drp;
	
	
	// Social relations 
	list<households> SN; 
	
	list<float> FPM  {
		
		float Fei <- ei * ( 1-rt * ib * (1-rp) );
		float Fib <- ib * (1- (1-rt) * (1 - ei) * (1-rp) );
		float Frp <- rp * (1- ib * rt * 0.5*p);// * ( (1-v) + v /( 1 + exp(-ei)) );
		
		if name = 'households0' {
			write("ei is "+ei+" ib is "+ib+" rp is "+rp);
			write("then the vec is "+[Fei,Fib,Frp]);
		}
		
		return [Fei,Fib,Frp];
	
	}
	
	float estimate_contagion {
		if length(SN) = 0 {
			return 0;
		} else {
			float ei_vec <- 0.0;
			
			loop hh over: SN {
				ei_vec <- ei_vec + hh.ei;
			}
			
			ei_vec <- ei_vec / length(SN);
			float fei <- rp * (1-(1-ei_vec) * (1-ei_vec)) + (1-rp)*ei_vec*ei;
			float Fei <- (fei-ei);
			
			return Fei;
		}
	}
	
	float estimate_mirroring {
		if length(SN) = 0 {
			return 0;
		} else {
			float ib_vec <- 0.0;
			
			loop hh over: SN {
				ib_vec <- ib_vec + hh.ei;
			}
			
			ib_vec <- ib_vec / length(SN);
			float fib <- rp * (1-(1-ib_vec) * (1-ib_vec)) + (1-rp)*ib_vec*ib;
			float Fib <- (fib-ib);
			
			return Fib;
		}
	}
	

	
	action updateEI {
		
//		Update emotional intensity
		float FSN_ei <- estimate_contagion();
		float Fei <- ei * ( 1-rt * ib * (1-rp) );
		
		dei <- (1-mu) * Fei + mu * FSN_ei;
		ei <- ei + dei;	
		
		if name = 'households1'{
			write('influence of sn on ei is '+FSN_ei);
		}
		
		}
	
	action updateRP {	
//		Update risk perception
		drp <- rp * (1- ib * rt * (1-p));
		rp <- rp + drp;// * ( (1-v) + v /( 1 + exp(-ei)) );
		}
		
	action updateIB {
		
//		Update information-seeking behaviour
		float FSN_ib <- estimate_mirroring();
		float Fib <- ib * ( 1- (1-rt) * (1-ei)*(1-rp));
		
		dib <- (1-mu) * Fib + mu * FSN_ib;
		ib <- ib + dib;	
		
		
		if name = 'households1'{
			write('event is '+rt);			
			write('influence of sn on ib is '+FSN_ib);
			write("new ei is "+ei+" new ib is "+ib+" new rp is "+rp);

		}
	} 
	
	reflex live {
		
		if name = 'households0'{
			write cycle;
		}

		do updateEI;
		do updateRP;
		do updateIB;
	}
	
	
}



experiment behaviour type: gui {
	/** Insert here the definition of the input and output of the model */
	
	parameter "event intensity" var: rt min:0 max: 1 step:1 ; 
	
	
	output {
		
		monitor "ei0" value: households[0].ei0;
		monitor "ib0" value: households[0].ib0;
		monitor "rp0" value: households[0].rp0;
		monitor "mu" value: households[0].mu;
		monitor "p" value: households[0].p;
		
		monitor "ei" value: households[0].ei;
		monitor "ib" value: households[0].ib;
		monitor "rp" value: households[0].rp;
		
	
		display data_viz {
	       	chart "PM household 0" type: series y_range:[-1,1] x_range: [0,100] size: {1,0.5} position: {0, 0}{
	        data "ei" value: households[0].ei;
	        data "ib" value: households[0].ib;
	        data "rp" value: households[0].rp; 
	        
	    }
	    
	    }
	    
	    display lala {    
		   	chart "d PMs" type: series y_range:[-1,1] x_range: [0,20] size: {1,0.5} position: {0, 0}{
		    data "D ei" value: households[0].dei;// sum_of each.ei / length(households); 
		    data "D ib" value: households[0].dib;// sum_of each.ib / length(households); 
		    data "d rp" value: households[0].drp;// sum_of each.rp / length(households); 	        
	    }
	    
//	    display lala {    
//		   	chart "avg PMs" type: series y_range:[-1,1] x_range: [0,20] size: {1,0.5} position: {0, 0}{
//		    data "avg ei" value: households sum_of each.ei / length(households); 
//		    data "avg ib" value: households sum_of each.ib / length(households); 
//		    data "avg rp" value: households sum_of each.rp / length(households); 	        
//	    }
	    
	    
	    	    
	    }
		
		
		
		 
	}
}
