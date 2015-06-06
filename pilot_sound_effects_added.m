


ignore_emg =            1;          % 1: Force good EMG
emg_channels =          18:21;      % Default: 18:21
use_full_go =           0;          % 1: Average all segments in 'go' block, 0: Average 'average_segs' segments
average_segs =          4;          % Number of segments to average (500ms) when use_full_go is 0
base_segs =             20;          % Number of segments to use for baseline (500ms)
bmin =                  15;         % Beta band floor
bmax =                  30;         % Beta band ceiling
fmin =                  25;         % EMG band floor
fmax =                  100;        % EMG band ceiling
hz =                    1000;       % Sampling rate (Hz)
fft_nbins =             512;        % Power of 2 close to size(indat,2)
alphaval =              0.05;       % Significance for EMG power t-test
  
x = 7; 
lowtrig = 10;   % below 10 is considered 0 because 'zero' fluctuates
right_cutoff_trig = 100;  
rest_cutoff_trig = 160;

% Initialize variables on the first run
 
indat(end,:) = round(indat(end,:));
trig_base = min(indat(end,:));

if ~exist('data','var')
    
    data.trigger_state = [];
    data.left_beta_power = [];
    data.right_beta_power = [];
    data.left_beta_ers = [];
    data.right_beta_ers = [];
    data.left_baseline = zeros;
    data.right_baseline = zeros; 
    current_state = 0;
    data.left_scores = [];
    data.right_scores = [];
    data.left_scores_raw = [];
    data.right_scores_raw = [];
    R =      25;          %factor the ERD is multiplied by to scale for difficulty (ie, starts at 1)
    L =      0;
    present_sound = 0;

right_score = 1;
t = 1;
p = 5;
q = 2;
y = 0; 
level_up = 5;
level_down = 1;
performance_right = 0;
performance_left = 0;
b = 1;
right_difficulty = 1;
left_difficulty = 1; 

end

indat(end,:) = indat(end,:) - trig_base;
 
left_fft_data = fft(indat(2,:),fft_nbins,2);
    left_fft_data_amp = sqrt(left_fft_data.*conj(left_fft_data));
    left_f = hz/2*linspace(0,1,fft_nbins/2+1);
    left_freqInd = find(left_f>bmin & left_f<bmax);
    left_beta_temp = mean(left_fft_data_amp(left_freqInd));

 data.left_beta_power = [data.left_beta_power; left_beta_temp];
 
right_fft_data = fft(indat(14,:),fft_nbins,2);
    right_fft_data_amp = sqrt(right_fft_data.*conj(right_fft_data));
    right_f = hz/2*linspace(0,1,fft_nbins/2+1);
    right_freqInd = find(right_f>bmin & right_f<bmax);
    right_beta_temp = mean(right_fft_data_amp(right_freqInd));

 data.right_beta_power = [data.right_beta_power; right_beta_temp];
 


 
 
% Trigger actions
 
data.trigger_state(end+1) = round(max(indat(end,:)));


 
% If a go trigger is received
if data.trigger_state(end) < rest_cutoff_trig && data.trigger_state(end) > lowtrig
    
    % Set the current state to 'go' and create 2 beta power baselines
    if t == 1
        t = 2;
    end
    
   y = 1;
   
    current_state = data.trigger_state(end);
    if b < 2
        
   b = b+1; 
   data.left_baseline = mean(data.left_beta_power(end-base_segs:end-1,:),1);
    data.right_baseline = mean(data.right_beta_power(end-base_segs:end-1,:),1);
    
   end
  
    % If a rest trigger is received
elseif data.trigger_state(end) > rest_cutoff_trig 
    condition = 3;
    current_state = data.trigger_state(end);
   %data.left_baseline = zeros;
    %data.right_baseline = zeros;

     performance_right = mean(data.right_scores(end-30:end));

    
    y = 2; 
    
    
    
    if t == 2 
        if performance_right >= p
            present_sound = 1;
        
      
        
            if right_difficulty == 1 
            level_up = 5;
            level_down = 2;
           
            elseif right_difficulty == 2 
            
        
            level_up = 7;
         
            
            
            elseif right_difficulty == 3 
            
            L = 25;
            R = 0;
            level_up = -1;
            level_down = -4;
            
            elseif right_difficulty == 4 || 5 
          
            level_up = level_up+2;
            level_down = level_down+2;
            
          
             elseif right_difficulty == 6
          
            R= 25;
            level_up = level_up+2;
            level_down = level_down+2;
           
            elseif right_difficulty >6
            level_up = level_up+3;
            level_down = level_down+2;
            

            end
            
            right_difficulty = right_difficulty+1;  
        end
    end
    
    if t==2 
        
        if  performance_right <= q
            present_sound = 2;
          
            
            if right_difficulty >7
            level_up = level_up-3;
            level_down = level_down-2;
           

            
            
            elseif right_difficulty == 7 
                if t>1
                
                    
                R = 0;
                level_up = level_up-2;
                level_down = level_down-2;
                %if L<0
                  %  L = 0;
               % end
                end
                
                
            elseif right_difficulty == 6 || 5 
                if t>1
                    
                level_up = level_up-2;
                level_down = level_down-2;
                %if L<0
                  %  L = 0;
               % end
                end
             
       
            
            elseif right_difficulty == 4
                 
                R = 25; 
                L = 0;
                level_up = level_up+8;
                level_down = level_down+6;
            
            elseif right_difficulty <4
                level_up = level_up-2;
                level_down = level_down-2;
                
            end
                
                
                
          
                 
           right_difficulty = right_difficulty-1;
                 
           
           if right_difficulty <1
                right_difficulty = 1;
           end
                 
         end
     end
    
    
   
    % Calculate mean_ers values (ie, changes from baseline) for each dipole and use these values to calculate scores presentation can identify and act on to change its video settings

    % If no trigger is received but you're in a go segment
elseif data.trigger_state(end) == 0 && current_state < right_cutoff_trig
    
    
  
        data.left_beta_ers(end+1,:) = log2(data.left_beta_power(end,:)./data.left_baseline);
   
    data.right_beta_ers(end+1,:) = log2(data.right_beta_power(end,:)./data.right_baseline);
    
    condition = 1;
    
    
elseif data.trigger_state(end) == 0 && current_state > right_cutoff_trig && current_state < rest_cutoff_trig
    
     data.left_beta_ers(end+1,:) = log2(data.left_beta_power(end,:)./data.left_baseline);
   
    data.right_beta_ers(end+1,:) = log2(data.right_beta_power(end,:)./data.right_baseline);
    
    condition = 2;
    
end
    
if use_full_go == 1, waitsegs = 0; else waitsegs = average_segs - 1; end

if (current_state < rest_cutoff_trig) && (unique(data.trigger_state(end-waitsegs:end)) < lowtrig)
   
        if use_full_go == 1
        
        % average_segs becomes the number of no-trigger segments since 'go'
        
        trig_inds = find(data.trigger_state > lowtrig);
        last_trig = trig_inds(end);
        average_segs = length(data.trigger_state) - last_trig;
        
        end

end


%%%%%%%TRIGGER ACTIONS COMPLETE


    left_ers = data.left_beta_ers(end-(x-1):end);
    left_ers = mean(left_ers);   


    right_ers = data.right_beta_ers(end-(x-1):end);
    right_ers = mean(right_ers);  

    

   %%%COMPUTE SCORES 
    
 right_ers = right_ers*L;
 left_ers = left_ers*R;    
 
        
if left_ers < 0, 
    left_ers_score = abs(left_ers); 
    right_score_raw = left_ers_score + right_ers;
elseif left_ers >0
    left_ers_score = left_ers*-1;
    right_score_raw = left_ers_score + right_ers; 
elseif left_ers == 0
    right_score_raw = right_ers; 
    

end
data.right_scores_raw(end+1) = right_score_raw;


%moving_score = mean(data.right_scores_raw(end-x:end)); 

 if y>1
     right_score = 1;
 elseif right_score_raw > level_up
    right_score = right_score+1;
     data.right_scores_raw(1:end)= 0;
     %  data.right_scores_raw(1:end)= [];
     
     
     
     
     if right_score >6
         right_score = 6;
     end
elseif right_score_raw < level_down
        right_score = right_score-1; 
        data.right_scores_raw(1:end)= 0;
       %data.right_scores_raw(1:end)= [];
        if right_score < 1
            right_score = 1;
        end
end

data.right_scores(end+1) = right_score;




        subplot(2,2,1); bar([-right_ers -left_ers]);    % Left hand to left side, flipped so ERD is up
        ylim([-15 45]); title('Beta ERD')
     subplot(2,2,2); bar(right_score_raw);    
        ylim([-40 15]); title('moving score')
         subplot(2,2,3); bar(right_difficulty);    
        ylim([0 8]); title('Difficulty level')
        subplot(2,2,4); bar(right_score);    
        ylim([0 7]); title('right score')
     




if condition == 1
    %fwrite(s,left_score_raw)
elseif condition ==2
    fwrite(s,right_score)
elseif condition == 3
    fwrite(s,present_sound)
    
end




