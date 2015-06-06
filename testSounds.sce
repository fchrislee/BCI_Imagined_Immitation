write_codes = true;

begin;

##define all audio
	sound { wavefile { filename = "smw_power-up.wav"; } ; } goodSound;
	sound { wavefile { filename = "smw_fireball.wav"; } ; } badSound;
	

trial {
	trial_duration = 8000;		
	picture {
		bitmap { filename = "fixation.png" ; } ; x=0 ; y=0 ;
	};
	port_code = 192;
	code = "code_rest";
} no_sound_trial_rest;


trial {
	trial_duration = 8000;		
	sound goodSound;
	picture {
		bitmap { filename = "fixation.png" ; } ; x=0 ; y=0 ;
	};
	port_code = 192;
	code = "code_rest";
	stimulus_event {
			sound goodSound;
			time = 1;
	};
} good_sound_trial_rest;


trial {
	trial_duration = 8000;		
	picture {
		bitmap { filename = "fixation.png" ; } ; x=0 ; y=0 ;
	};
	port_code = 192;
	code = "code_rest";
	stimulus_event {
		sound badSound;
		time = 2;
		};
} bad_sound_trial_rest;













begin_pcl;

input_port serial = input_port_manager.get_port( 1 );

int i = 1;
if serial.total_count() < 1 then
	i = serial.last_code();
end;
	##Good
	if i == 1 then
		good_sound_trial_rest.present();

	##Bad
	elseif i == 2  then
		bad_sound_trial_rest.present();

	elseif i == 3  then
		no_sound_trial_rest.present();

	end;
