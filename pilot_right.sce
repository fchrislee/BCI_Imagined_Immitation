write_codes = true;

begin;

##define all videos
	video { filename = "v1.avi"; custom_display = true; use_audio = false; } v1;
	video { filename = "v2.avi"; custom_display = true; use_audio = false; } v2;
	video { filename = "v3.avi"; custom_display = true; use_audio = false; } v3;
	video { filename = "v4.avi"; custom_display = true; use_audio = false; } v4;
	video { filename = "v5.avi"; custom_display = true; use_audio = false; } v5;
	video { filename = "v6.avi"; custom_display = true; use_audio = false; } v6;

##define all audio
	wavefile { filename = "smw_power-up.wav"; } goodWave;
	wavefile { filename = "smw_fireball.wav"; } badWave;
	sound { wavefile goodWave; } goodSound;
	sound { wavefile badWave; } badSound;
	
	
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


begin_pcl;

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


