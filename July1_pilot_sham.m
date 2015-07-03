
 %%SECTION 1 = set up variables/ specify the fundamental calculations to be
 %%done on the data throughout 

 
 %%%%SHAM NOTE.... YOU MUST LOAD A VECTOR OF SOUND VALUES INTO THE COMMAND
 %%%%WINDOW AND SAVE IT AS 'sounds' IN ORDER FOR THE CODE TO WORK. 
 
 %%%NOTE FOR KARL--YOU CAN LIKELY CUT OUT EVEN MORE CODE THAN I HAVE HERE
 %%%FROM THE ORIGINAL. BASICALLY ALL THIS CODE NEEDS TO DO IS (1) MAKE SURE THE
 %%%CORRECT 'SOUND' VALUE IS BEING SENT THROUGH THE PORT WHEN REST TRIGGERS
 %%%ARE RECEIVED--THIS IS ALREADY DONE (2)  PLOT AND SAVE GRAPHS BASED
 %%%ON A PRE-DETERMINED ARRAY FILLED WITH DIFFICULTY LEVELS--IE, DURING THE
 %%%FIRST REST PERIOD PLOT THE FIRST VALUE IN THE ARAY. ON THE SECOND, PLOT
 %%%THE FIRST TWO. SO ON AND SO FORTH UNTIL IT FINALLY PLOTS THE WHOLE
 %%%ARRAY IN THE LAST REST PERIOD
 
 %%%I say first rest period above, because the VERY first presentation
 %%%trial (the fixation cross) does not send a trigger value to matlab and
 %%%thus is not technically the first rest period. 
 
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
    a = 1;      %index for sound sham values
    p = 5; % score threshold for difficulty +1
    q = 2; % score threshold for difficulty -1
    y = 0; % variable used to keep the scores at 1 during rest
    c = 1; % constant allowing you to tweak where the difficulty starts at (all threshold values are 
    %multiplied by it so you can tweak starting difficulty by just changing this one value)
    level_up = 1*c;
    level_down = -2*c;
    performance_lastbock = 0;
    u = 1; %variable used to index the sham scores to be sent out via the serial port

    b = 1; % variable used to ensure the baseline only gets calcuated when the first go trigger is received
    right_difficulty = 1;
end

%this line below just removes any pre-existing noise that may exist in the
%presentation trigger channel
indat(end,:) = indat(end,:) - trig_base;
 
 %%%SECTION 2 = Trigger actions
 
data.trigger_state(end+1) = round(max(indat(end,:)));

% 2-1 If a go trigger is received
if data.trigger_state(end) < rest_cutoff_trig && data.trigger_state(end) > lowtrig
    
  
    current_state = data.trigger_state(end);
   
    %code below sets the variable sound (determining whether/which sound
    %will play during the next rest period to a value in the array 'sounds'
    %which should have been loaded into the command window at the beginning
    %of the session
    sound = sounds(a);
    a = a+1;
    
    % 2-2 If a rest trigger is received
elseif data.trigger_state(end) > rest_cutoff_trig 
    condition = 3; 
    current_state = data.trigger_state(end);
   
   
    
    y = 2; 
   

    
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
    fwrite(s, sounds)
else
    fwrite(s,shame_scores(u))
end

u = u+1;




