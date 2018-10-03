% produce pure audio tones at random intervals

disp('Press CTRL-C in Command Window to Stop') ;
disp('Playing Tones...') ;

min_interval = 1 ; % inter tone interval in sec
max_interval = 5 ;

tone_duration = 1 ; % sec
tone_freq_list = [1000 10000] ; % Hz

sampling_freq = 96000 ; % playback samples/sec

channel_mode = {'both','random'} ;
current_mode = channel_mode{1} ;
channel_mask = [0 1; 1 0] ;

% build the tone buffers
tone_buffer = {} ;
for ii=1:length(tone_freq_list)
    num_samples_per_cycle = sampling_freq/tone_freq_list(ii) ;
    cycle_buf = sin([0:1:num_samples_per_cycle]*2*pi/num_samples_per_cycle) ;
    num_cycles_per_tone = tone_duration*tone_freq_list(ii) ;
    tone_buffer{ii} = repmat(cycle_buf,1,ceil(num_cycles_per_tone)) ;
end    


done = false ;
used_tones = ones(length(tone_freq_list),1) ; % list that holds ids of elements used up in tone freq random list
while ~done
%   get wait time
    wait_time = min_interval + rand*(max_interval - min_interval) ;

    %   get the tone index in list, replenish order list if it is
    %   exhausted
    if (sum(used_tones) == length(tone_freq_list))
        used_tones = used_tones*0 ;
        tone_order = randperm(length(tone_freq_list)) ;
    end
    idx = find(used_tones==0) ;    
    tone_type = tone_order(idx(1)) ;
    used_tones(idx(1)) = 1 ;

%   setup tone buffer based on channel mode    
    tone_buf = tone_buffer{tone_type}' ;
    tone_buf = [tone_buf tone_buf] ;
    if strcmp(current_mode,'random')
        blank_chan = double(rand > 0.5)+1 ;
        tone_buf = tone_buf.*channel_mask(blank_chan,:) ;
    end 

%   create player object 
    if (isvalid(p))
        delete(p) ;
    end
    p = audioplayer(tone_buf, sampling_freq) ;
    
%   play and wait for end of playback   
    play(p) ;
    while isplaying(p)
        pause(0.01) ;
    end
 
%   remove player object    
    delete(p) ;

%   wait for random inter tone time
    pause(wait_time) ;
end
