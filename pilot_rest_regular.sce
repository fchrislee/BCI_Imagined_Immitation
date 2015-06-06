write_codes = true;

begin;


trial {
		trial_duration = 8000; 
		picture {
				bitmap { filename = "fixation.png" ; } ; x=0 ; y=0 ;
					};
			
			port_code = 192;
			code = "code_rest";

} trial_rest;


begin_pcl;

trial_rest.present()