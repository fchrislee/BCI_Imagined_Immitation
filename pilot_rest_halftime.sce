active_buttons = 1;
button_codes = 0;
write_codes = true;
response_logging = log_active;
response_matching = simple_matching;
default_background_color = 0,0,0;



begin;


trial {
	trial_duration = forever;
	trial_type = first_response;	
		picture {
				bitmap { filename = "rest.jpg" ; } ; x=0 ; y=0 ;
					};
			
			port_code = 192;
			code = "code_rest";

} trial_rest_halftime;


begin_pcl;

trial_rest_halftime.present()

