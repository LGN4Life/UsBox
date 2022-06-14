function stimulus  = LoadStimLevels(channel_info,fhand)


%load stim levels

%annoyingly, the CED library requires an imput that sets a limit to the
%number of spike times to load. If you set an unreasonably large value, it
%grind the system to a halt
%Use a relatively small value, then loop and concatenate
max_events = 1000; 



stim_channel_number = channel_info.number(strcmp(channel_info.names,'Stim'));



stim_levels = [];
exit_flag= false;
start_tick=0;
while ~exit_flag
    
    
    [ ~, current_stim_levels,~ ] = CEDS64ReadLevels(fhand, stim_channel_number, max_events, start_tick);
    
    stim_levels = cat(1,stim_levels,current_stim_levels);
    if length(current_stim_levels) ~=  max_events
        
        exit_flag = true;
    else
        start_tick = current_stim_times(end)+1;
    end
end





stim_levels = CEDS64TicksToSecs(fhand,stim_levels);
stimulus = reshape(stim_levels,2,length(stim_levels)/2);

