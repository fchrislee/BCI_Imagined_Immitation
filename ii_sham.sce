write_codes = true;

begin;

##define all videos
	video { filename = "v1_short.avi"; custom_display = true; use_audio = false; } v1_short;
	video { filename = "v2_short.avi"; custom_display = true; use_audio = false; } v2_short;
	video { filename = "v3_short.avi"; custom_display = true; use_audio = false; } v3_short;
	video { filename = "v4_short.avi"; custom_display = true; use_audio = false; } v4_short;
	video { filename = "v5_short.avi"; custom_display = true; use_audio = false; } v5_short;
	video { filename = "v6_short.avi"; custom_display = true; use_audio = false; } v6_short;
	
	video { filename = "v1_long.avi"; custom_display = true; use_audio = false; } v1_long;
	video { filename = "v2_long.avi"; custom_display = true; use_audio = false; } v2_long;
	video { filename = "v3_long.avi"; custom_display = true; use_audio = false; } v3_long;
	video { filename = "v4_long.avi"; custom_display = true; use_audio = false; } v4_long;
	video { filename = "v5_long.avi"; custom_display = true; use_audio = false; } v5_long;
	video { filename = "v6_long.avi"; custom_display = true; use_audio = false; } v6_long;


	video { filename = "v1.avi"; custom_display = true; use_audio = false; } v1;
	video { filename = "v2.avi"; custom_display = true; use_audio = false; } v2;
	video { filename = "v3.avi"; custom_display = true; use_audio = false; } v3;
	video { filename = "v4.avi"; custom_display = true; use_audio = false; } v4;
	video { filename = "v5.avi"; custom_display = true; use_audio = false; } v5;
	video { filename = "v6.avi"; custom_display = true; use_audio = false; } v6;
##define all audio
	sound { wavefile { filename = "good.wav"; } ; } goodSound;
	sound { wavefile { filename = "bad.wav"; } ; } badSound;
	
	
##trial video play

trial {
	stimulus_event {
		picture {
			plane {
				height = 980; width = 1400; emissive = 1.0,1.0,1.0; alpha = 1.0;
					} plane_1;
				x = 0; y = 0; z = 0;
				
			plane {
				height = 980; width = 1400; emissive = 1.0,1.0,1.0; alpha = 0.2;
					} plane_2;
				x = 0; y = 0; z = 0;
				plane {
				height = 980; width = 1400; emissive = 1.0,1.0,1.0; alpha = 0.2;
					} plane_3;
				x = 0; y = 0; z = 0;
				plane {
				height = 980; width = 1400; emissive = 1.0,1.0,1.0; alpha = 0.2;
					} plane_4;
				x = 0; y = 0; z = 0;
				plane {
				height = 980; width = 1400; emissive = 1.0,1.0,1.0; alpha = 0.2;
					} plane_5;
				x = 0; y = 0; z = 0;
				plane {
				height = 980; width = 1400; emissive = 1.0,1.0,1.0; alpha = 0.2;
					} plane_6;
				x = 0; y = 0; z = 0;
			} my_pic;
			port_code = 128;
			code = "code_vid_1_r";
		} vid;
} trial_vid_1_r;

# rest screen trials

trial {
	trial_duration = 8000;		
	picture {
		bitmap { filename = "fixation.png" ; } ; x=0 ; y=0 ;
	};
	code = "code_rest";
} no_sound_trial_rest;


trial {
	trial_duration = 8000;		
	sound goodSound;
	picture {
		bitmap { filename = "fixation.png" ; } ; x=0 ; y=0 ;
	};
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

	code = "code_rest";
	stimulus_event {
		sound badSound;
		time = 2;
		};
} bad_sound_trial_rest;

#initial, fixation cross trial

trial {
		trial_duration = 20000; 
		picture {
				bitmap { filename = "fixation.png" ; } ; x=0 ; y=0 ;
					};
			
			
			code = "code_rest";

} trial_rest_long;


###PCL mother fucker!

begin_pcl;



# subroutine for regular rest screen 

sub
	rest
begin
	output_port LPT1 = output_port_manager.get_port(1);
	input_port serial = input_port_manager.get_port( 1 );

	LPT1.send_code(192);

	int last_code = serial.last_code();
	loop
	until
		last_code == 7 || last_code == 8 || last_code == 9
	begin
		loop
			int code_ct = serial.total_count()
		until
			serial.total_count() > code_ct
		begin
	
		end;
		last_code = serial.last_code();
	end;

	if ( last_code == 7 ) then
		good_sound_trial_rest.present();
	elseif( last_code == 8 ) then
		bad_sound_trial_rest.present();
	elseif( last_code == 9 ) then
		no_sound_trial_rest.present();
	end;
end;

# subroutine for initial rest trial 
sub
	rest_long
begin
	trial_rest_long.present();
end;

#BELOW subs for all task blocks : short, reg, long versions

sub
	ii_short
begin
	input_port serial = input_port_manager.get_port( 1 );

	loop

	int i = 1;

	until

		i>1
	
	begin 
	v1_short.prepare();
	v2_short.prepare();
	v3_short.prepare();
	v4_short.prepare();
	v5_short.prepare();
	v6_short.prepare();

	plane_1.set_texture( v1_short.get_texture() );
	plane_2.set_texture( v2_short.get_texture() );
	plane_3.set_texture( v3_short.get_texture() );
	plane_4.set_texture( v4_short.get_texture() );
	plane_5.set_texture( v5_short.get_texture() );
	plane_6.set_texture( v6_short.get_texture() );

	plane_1.set_alpha( 1.0 );
	plane_2.set_alpha( 0.0 );
	plane_3.set_alpha( 0.0 );
	plane_4.set_alpha( 0.0 );
	plane_5.set_alpha( 0.0 );
	plane_6.set_alpha( 0.0 );

	trial_vid_1_r.present();
	int vid_start_time = stimulus_manager.last_stimulus_data().time();

	loop
    	int next_frame = vid_start_time + int( v1_short.current_frame_end() );
	until
    	false
	begin
    	if ( clock.time() >= next_frame ) then
        	if ( !v1_short.advance() || !v2_short.advance() || !v3_short.advance() || !v4_short.advance() || !v5_short.advance() || !v6_short.advance() ) then
            	if ( v1_short.frame_position() < v1_short.frame_duration() && v2_short.frame_position() < v2_short.frame_duration() ) then
                	term.print_line( "Video Desync" );
            	end;
					break;
        	end;
        	my_pic.present();
    	end;
			int s = serial.last_code();
	
		
		if s == 31 then
			int p = serial.total_count();
			s = serial.codes(p-1);
		end;	
		if s == 1 then
			plane_1.set_alpha( 1.0 );
			plane_2.set_alpha( 0.0 );
			plane_3.set_alpha( 0.0 );
			plane_4.set_alpha( 0.0 );
			plane_5.set_alpha( 0.0 );
			plane_6.set_alpha( 0.0 );
		elseif s == 2 then
			plane_1.set_alpha( 0.0 );
			plane_2.set_alpha( 1.0 );
			plane_3.set_alpha( 0.0 );
			plane_4.set_alpha( 0.0 );
			plane_5.set_alpha( 0.0 );
			plane_6.set_alpha( 0.0 );
		
		elseif s == 3 then
			plane_1.set_alpha( 0.0 );
			plane_2.set_alpha( 0.0 );
			plane_3.set_alpha( 1.0 );
			plane_4.set_alpha( 0.0 );
			plane_5.set_alpha( 0.0 );
			plane_6.set_alpha( 0.0 );
		elseif s == 4 then
			plane_1.set_alpha( 0.0 );
			plane_2.set_alpha( 0.0 );
			plane_3.set_alpha( 0.0 );
			plane_4.set_alpha( 1.0 );
			plane_5.set_alpha( 0.0 );
			plane_6.set_alpha( 0.0 );
		elseif s == 5 then
			plane_1.set_alpha( 0.0 );
			plane_2.set_alpha( 0.0 );
			plane_3.set_alpha( 0.0 );
			plane_4.set_alpha( 0.0 );
			plane_5.set_alpha( 1.0 );
			plane_6.set_alpha( 0.0 );
		elseif s == 6 then
			plane_1.set_alpha( 0.0 );
			plane_2.set_alpha( 0.0 );
			plane_3.set_alpha( 0.0 );
			plane_4.set_alpha( 0.0 );
			plane_5.set_alpha( 0.0 );
	end;	
    next_frame = vid_start_time + int( v1_short.current_frame_end() );
end;
i = i+1
end;
v1_short.release();
v2_short.release();
v3_short.release();
v4_short.release();
v5_short.release();
v6_short.release();
end;



sub
	ii_long
begin
	input_port serial = input_port_manager.get_port( 1 );

	loop

	int i = 1;

	until

		i>1
	
	begin 
	v1_long.prepare();
	v2_long.prepare();
	v3_long.prepare();
	v4_long.prepare();
	v5_long.prepare();
	v6_long.prepare();

	plane_1.set_texture( v1_long.get_texture() );
	plane_2.set_texture( v2_long.get_texture() );
	plane_3.set_texture( v3_long.get_texture() );
	plane_4.set_texture( v4_long.get_texture() );
	plane_5.set_texture( v5_long.get_texture() );
	plane_6.set_texture( v6_long.get_texture() );

	plane_1.set_alpha( 1.0 );
	plane_2.set_alpha( 0.0 );
	plane_3.set_alpha( 0.0 );
	plane_4.set_alpha( 0.0 );
	plane_5.set_alpha( 0.0 );
	plane_6.set_alpha( 0.0 );

	trial_vid_1_r.present();
	int vid_start_time = stimulus_manager.last_stimulus_data().time();

	loop
    	int next_frame = vid_start_time + int( v1_long.current_frame_end() );
	until
    	false
	begin
    	if ( clock.time() >= next_frame ) then
        	if ( !v1_long.advance() || !v2_long.advance() || !v3_long.advance() || !v4_long.advance() || !v5_long.advance() || !v6_long.advance() ) then
            	if ( v1_long.frame_position() < v1_long.frame_duration() && v2_long.frame_position() < v2_long.frame_duration() ) then
                	term.print_line( "Video Desync" );
            	end;
					break;
        	end;
        	my_pic.present();
    	end;
			int s = serial.last_code();
	
		
		if s == 31 then
			int p = serial.total_count();
			s = serial.codes(p-1);
		end;	
		if s == 1 then
			plane_1.set_alpha( 1.0 );
			plane_2.set_alpha( 0.0 );
			plane_3.set_alpha( 0.0 );
			plane_4.set_alpha( 0.0 );
			plane_5.set_alpha( 0.0 );
			plane_6.set_alpha( 0.0 );
		elseif s == 2 then
			plane_1.set_alpha( 0.0 );
			plane_2.set_alpha( 1.0 );
			plane_3.set_alpha( 0.0 );
			plane_4.set_alpha( 0.0 );
			plane_5.set_alpha( 0.0 );
			plane_6.set_alpha( 0.0 );
		
		elseif s == 3 then
			plane_1.set_alpha( 0.0 );
			plane_2.set_alpha( 0.0 );
			plane_3.set_alpha( 1.0 );
			plane_4.set_alpha( 0.0 );
			plane_5.set_alpha( 0.0 );
			plane_6.set_alpha( 0.0 );
		elseif s == 4 then
			plane_1.set_alpha( 0.0 );
			plane_2.set_alpha( 0.0 );
			plane_3.set_alpha( 0.0 );
			plane_4.set_alpha( 1.0 );
			plane_5.set_alpha( 0.0 );
			plane_6.set_alpha( 0.0 );
		elseif s == 5 then
			plane_1.set_alpha( 0.0 );
			plane_2.set_alpha( 0.0 );
			plane_3.set_alpha( 0.0 );
			plane_4.set_alpha( 0.0 );
			plane_5.set_alpha( 1.0 );
			plane_6.set_alpha( 0.0 );
		elseif s == 6 then
			plane_1.set_alpha( 0.0 );
			plane_2.set_alpha( 0.0 );
			plane_3.set_alpha( 0.0 );
			plane_4.set_alpha( 0.0 );
			plane_5.set_alpha( 0.0 );
	end;	
    next_frame = vid_start_time + int( v1_long.current_frame_end() );
end;
i = i+1
end;
v1_long.release();
v2_long.release();
v3_long.release();
v4_long.release();
v5_long.release();
v6_long.release();
end;


sub
	ii_reg
begin
	input_port serial = input_port_manager.get_port( 1 );

loop

int i = 1;

until

	i>1
	
begin 
v1.prepare();
v2.prepare();
v3.prepare();
v4.prepare();
v5.prepare();
v6.prepare();




plane_1.set_texture( v1.get_texture() );
plane_2.set_texture( v2.get_texture() );
plane_3.set_texture( v3.get_texture() );
plane_4.set_texture( v4.get_texture() );
plane_5.set_texture( v5.get_texture() );
plane_6.set_texture( v6.get_texture() );

plane_1.set_alpha( 1.0 );
plane_2.set_alpha( 0.0 );
plane_3.set_alpha( 0.0 );
plane_4.set_alpha( 0.0 );
plane_5.set_alpha( 0.0 );
plane_6.set_alpha( 0.0 );

trial_vid_1_r.present();
int vid_start_time = stimulus_manager.last_stimulus_data().time();

loop
    int next_frame = vid_start_time + int( v1.current_frame_end() );
until
    false
begin
    if ( clock.time() >= next_frame ) then
        if ( !v1.advance() || !v2.advance() || !v3.advance() || !v4.advance() || !v5.advance() || !v6.advance() ) then
            if ( v1.frame_position() < v1.frame_duration() && v2.frame_position() < v2.frame_duration() ) then
                term.print_line( "Video Desync" );
            end;
				break;
        end;
        my_pic.present();
    end;
		int s = serial.last_code();
	
		
	if s == 31 then
		int p = serial.total_count();
		s = serial.codes(p-1);
	end;	
	if s == 1 then
		plane_1.set_alpha( 1.0 );
		plane_2.set_alpha( 0.0 );
		plane_3.set_alpha( 0.0 );
		plane_4.set_alpha( 0.0 );
		plane_5.set_alpha( 0.0 );
		plane_6.set_alpha( 0.0 );
	elseif s == 2 then
		plane_1.set_alpha( 0.0 );
		plane_2.set_alpha( 1.0 );
		plane_3.set_alpha( 0.0 );
		plane_4.set_alpha( 0.0 );
		plane_5.set_alpha( 0.0 );
		plane_6.set_alpha( 0.0 );
		
	elseif s == 3 then
		plane_1.set_alpha( 0.0 );
		plane_2.set_alpha( 0.0 );
		plane_3.set_alpha( 1.0 );
		plane_4.set_alpha( 0.0 );
		plane_5.set_alpha( 0.0 );
		plane_6.set_alpha( 0.0 );
	elseif s == 4 then
		plane_1.set_alpha( 0.0 );
		plane_2.set_alpha( 0.0 );
		plane_3.set_alpha( 0.0 );
		plane_4.set_alpha( 1.0 );
		plane_5.set_alpha( 0.0 );
		plane_6.set_alpha( 0.0 );
	elseif s == 5 then
		plane_1.set_alpha( 0.0 );
		plane_2.set_alpha( 0.0 );
		plane_3.set_alpha( 0.0 );
		plane_4.set_alpha( 0.0 );
		plane_5.set_alpha( 1.0 );
		plane_6.set_alpha( 0.0 );
	elseif s == 6 then
		plane_1.set_alpha( 0.0 );
		plane_2.set_alpha( 0.0 );
		plane_3.set_alpha( 0.0 );
		plane_4.set_alpha( 0.0 );
		plane_5.set_alpha( 0.0 );
		plane_6.set_alpha( 1.0 );
	
		
	
	end;	
   
    next_frame = vid_start_time + int( v1.current_frame_end() );
end;

i = i+1

end;

v1.release();
v2.release();
v3.release();
v4.release();
v5.release();
v6.release();
end;


###BELOW JUST PUT IN WHICH SUBROUTINES YOU WANT TO RUN 
rest_long();
ii_short();

