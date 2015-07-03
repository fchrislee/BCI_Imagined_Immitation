
 %%SECTION 1 = set up variables/ specify the fundamental calculations to be
 %%done on the data throughout 

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
    data.right_difficulty = [];
    data.sounds = [];
    data.performance_lastblock = [];
    R =        10;          %factor the ERD is multiplied by to scale for difficulty (ie, starts at 1)
    L =      1;
    record = 0;
    right_score = 1;
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
    x =                        7;       % number of data segments to avg for ERD/ERS baseline
    lowtrig = 10;   % below 10 is considered 0 because 'zero' fluctuates
    rest_cutoff_trig = 160;  %value used to define rest vs go trigers
    right_cutoff_trig = 100; %another triger threshold to allow you to introduce >1 trial type

    p = 5; % score threshold for difficulty +1
    q = 2; % score threshold for difficulty -1
    y = 0; % variable used to keep the scores at 1 during rest
    c = 1; % constant allowing you to tweak where the difficulty starts at (all threshold values are 
    %multiplied by it so you can tweak starting difficulty by just changing this one value)
    level_up = 1*c;
    level_down = -2*c;
    performance_lastbock = 0;

    b = 1; % variable used to ensure the baseline only gets calcuated when the first go trigger is received
    right_difficulty = 1;
end

%this line below just removes any pre-existing noise that may exist in the
%presentation trigger channel
indat(end,:) = indat(end,:) - trig_base;

 % below is most of the mathematical heavily lifting 
 
left_fft_data = fft(indat([1,4],:),fft_nbins,2);
    left_fft_data_amp = sqrt(left_fft_data.*conj(left_fft_data));
    left_f = hz/2*linspace(0,1,fft_nbins/2+1);
    left_freqInd = find(left_f>bmin & left_f<bmax);
    left_beta_temp = mean(left_fft_data_amp(left_freqInd));

 data.left_beta_power = [data.left_beta_power; left_beta_temp];
 
right_fft_data = fft(indat([2,5],:),fft_nbins,2);
    right_fft_data_amp = sqrt(right_fft_data.*conj(right_fft_data));
    right_f = hz/2*linspace(0,1,fft_nbins/2+1);
    right_freqInd = find(right_f>bmin & right_f<bmax);
    right_beta_temp = mean(right_fft_data_amp(right_freqInd));

 data.right_beta_power = [data.right_beta_power; right_beta_temp];
 
 %%%SECTION 2 = Trigger actions
 
data.trigger_state(end+1) = round(max(indat(end,:)));

% 2-1 If a go trigger is received
if data.trigger_state(end) < rest_cutoff_trig && data.trigger_state(end) > lowtrig
    
    % Set the current state to 'go' and create 2 beta power baselines   
   y = 1;
   % if- below makes sure that score values are only beging saved to
   % file during task blocks
     if record <1
        record = record+1;
     end
     
    current_state = data.trigger_state(end);
    
    % if- below calculates baseline on occasion of first go trigger
    if b < 2  
   b = b+1; 
   data.left_baseline = mean(data.left_beta_power(end-base_segs:end-1,:),1);
    data.right_baseline = mean(data.right_beta_power(end-base_segs:end-1,:),1);  
   end
  
    % 2-2 If a rest trigger is received
elseif data.trigger_state(end) > rest_cutoff_trig 
    condition = 3; 
    current_state = data.trigger_state(end);
   %data.left_baseline = zeros;
    %data.right_baseline = zeros;
    
    y = 2; 
   
    %%code below calculates score from the preceding block, then saves this
    %%value to file
    performance_lastbock = mean(data.right_scores(end-30:end));
    data.performance_lastblock(end+1) = performance_lastbock;
     fid=fopen('performance_int', 'wt');
     fprintf(fid,'%d\n',data.performance_lastblock);
     fclose(fid);
    
    %%series of ifs below evaluate if the difficulty setting should be +/-
    %%1 or not, sets the variable 'sound' accordingly; and then saves the new difficulty level/sound value to file, 
        if performance_lastbock <p && performance_lastbock >q
            sound = 9;
            data.right_difficulty(end+1) = right_difficulty;
            data.sounds(end+1) = sound;
            fid=fopen('sounds', 'wt');
            fprintf(fid,'%d\n',data.sounds);
            fclose(fid);
            fid=fopen('difficulty', 'wt');
            fprintf(fid,'%d\n',data.right_difficulty);
            fclose(fid);

        end
         
        if performance_lastbock >= p
            sound = 7;
            data.right_difficulty(end+1) = right_difficulty;
            data.sounds(end+1) = sound;
            fid=fopen('sounds', 'wt');
            fprintf(fid,'%d\n',data.sounds);
            fclose(fid);
            if right_difficulty == 1
                level_up = level_up+(2*c);
                level_down = level_down+(2*c);
            end
                   
            if right_difficulty == 2
                level_up = level_up+(2*c);
                level_down = level_down+(2*c);
                L = L+R*.1; 
            end
            
           if right_difficulty >2 && right_difficulty <11
              
                L = L+R*.1; 
           end
        
            if right_difficulty >10
              
               level_up = level_up+(3*c);
               level_down = level_down+(2*c);
           
            end
                
             if right_difficulty == 1.2
                level_up = level_up+(3*c);
                level_down = level_down+(3*c);
                right_difficulty = 1;
             elseif right_difficulty == 1.1
                level_up = level_up+(3*c);
                level_down = level_down+(3*c);
                right_difficulty = 1.2;
             else
                 right_difficulty = right_difficulty+1;
             end            
        
        elseif  performance_lastbock <= q
          if right_difficulty >1.2
              sound = 8;
              data.right_difficulty(end+1) = right_difficulty;
            data.sounds(end+1) = sound;
            fid=fopen('sounds', 'wt');
            fprintf(fid,'%d\n',data.sounds);
            fclose(fid);
            fid=fopen('difficulty', 'wt');
            fprintf(fid,'%d\n',data.right_difficulty);
            fclose(fid);
          else 
              sound = 9;
              data.right_difficulty(end+1) = right_difficulty;
            data.sounds(end+1) = sound;
            fid=fopen('sounds', 'wt');
            fprintf(fid,'%d\n',data.sounds);
            fclose(fid);
            fid=fopen('difficulty', 'wt');
            fprintf(fid,'%d\n',data.right_difficulty);
            fclose(fid);
          end
    
            if right_difficulty == 1.2
                level_up = level_up-(3*c);
                level_down = level_down-(3*c);
                right_difficulty = 1.1;
            end
            
            
            if right_difficulty == 2
                level_up = level_up-(2*c);
                level_down = level_down-(2*c);
               
            end
            
            if right_difficulty == 3
                level_up = level_up-(2*c);
                level_down = level_down-(2*c);
                L = L-R*.1; 
            end
            
           if right_difficulty >3 && right_difficulty <12
              
                L = L-R*.1; 
           end
           
           if right_difficulty >11
              
               level_up = level_up-(3*c);
               level_down = level_down-(2*c);
           end
            
            if right_difficulty == 1.1
                right_difficulty = 1.1;
            else
                right_difficulty = right_difficulty-1;
            end
         
         
            if right_difficulty <1
                right_difficulty = 1;
            end

        end
         
         %%if- sets the difficulty to 1.1 if the participant has been stuck
         %%on level 4 for four consequentive trials. From here they upgrade
         %%to 1.2, and then finally back to 1 where they started. 
         if mean(data.right_difficulty(end-2:end)) == 1
             right_difficulty = 1.1;
             level_up = level_up-(6*c);
             level_down = level_down-(6*c);   
         end
       

    
    % If no trigger is received but you're in a go segment
    % evaluating beta power changes from baseline
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


%%SECTION 3 = performance/score calculation

%takes the ongoing beta-change-from-baseline calculations and averages the
%last couple seconds
    left_ers = data.left_beta_ers(end-(x-1):end);
    left_ers = mean(left_ers);   

    right_ers = data.right_beta_ers(end-(x-1):end);
    right_ers = mean(right_ers);  

    
    %L/R factors used to ease in ipsilateral activity into the score
    %calculation
 right_ers = right_ers*L;
 left_ers = left_ers*R;     
        
 
 %laterality score calculation
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

%video score calculation
 if y>1
     right_score = 1;
 elseif right_score_raw > level_up
     
    if sum(data.right_scores(end-3:end)) == data.right_scores(end)*4
        right_score = right_score+1;
    end
 
    if right_score >6
        right_score = 6;
    end
    
     if right_score >6
         right_score = 6;
     end
elseif right_score_raw < level_down
    % if below makes it so that right_score cannot change more often than
    % once every 2 seconds
    if sum(data.right_scores(end-3:end)) == data.right_scores(end)*4
        right_score = right_score-1;

    end
 end
 
      if right_score <1
          right_score = 1;
      end
      
data.right_scores(end+1) = right_score;


% code that plots what you see in the MATLAB figure window
        subplot(2,2,1); bar([-right_ers -left_ers]);    % Left hand to left side, flipped so ERD is up
        ylim([-125 125]); title('Beta ERD')
     subplot(2,2,2); bar(right_score_raw);    
        ylim([-100 100]); title('moving score')
         subplot(2,2,3); bar(right_difficulty);    
        ylim([0 8]); title('Difficulty level')
        subplot(2,2,4); bar(right_score);    
        ylim([0 7]); title('right score')
     
% code saving all right_score values during task blocks
   if record >0
    fid=fopen('right_score_file', 'wt');
    fprintf(fid,'%d\n',data.right_scores);
    fclose(fid);
   end
   
%port output
if condition == 3
    fwrite(s, sound)
else
    fwrite(s,right_score)
end





