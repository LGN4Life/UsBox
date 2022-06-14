function keyboard_info = LoadKeyboardChannel(fhand,keyboard_channel_number)

keyboard_info = [];

exit_flag = false;
%annoyingly, the CED library requires an imput that sets a limit to the
%number of spike times to load. If you set an unreasonably large value, it
%grind the system to a halt
%Use a relatively small value, then loop and concatenate
max_events = 1000;
%start_tick : tell the CED librbary where you want to begin
%loading from.  Start and 0 and then start at maxPreviousTick+1
start_tick = 0;

keyboard_spike2=[];
while ~exit_flag
 
    [~ , current_keyboard ] = CEDS64ReadMarkers(fhand,  keyboard_channel_number, max_events, start_tick);
    keyboard_spike2 = cat(1,keyboard_spike2,current_keyboard);
    if length(current_keyboard) ~= max_events
        
        exit_flag = true;
    else
        start_tick = keyboard_spike2(end).m_Time+1;
    end
end


event_index =0;

for loop_index = 1:length(keyboard_spike2)
    
    
    current_time = CEDS64TicksToSecs(fhand,keyboard_spike2(loop_index).m_Time);
    
    keyboard_info.markers{loop_index} = keyboard_spike2(loop_index).m_Code1;
    keyboard_info.timestamps(loop_index) = current_time;
    
    
    
    
    
    
end






