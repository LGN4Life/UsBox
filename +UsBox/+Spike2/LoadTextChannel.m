function text_mark_info = LoadTextChannel(fhand,text_channel_number)

text_mark_info=[];

exit_flag = false;
%annoyingly, the CED library requires an imput that sets a limit to the
%number of spike times to load. If you set an unreasonably large value, it
%grind the system to a halt
%Use a relatively small value, then loop and concatenate
max_events = 1000;
%start_tick : tell the CED librbary where you want to begin
%loading from.  Start and 0 and then start at maxPreviousTick+1
start_tick = 0;

textmark_spike2=[];
while ~exit_flag
  
    [~ , current_textmark ] = CEDS64ReadExtMarks(fhand,  text_channel_number, max_events, start_tick);
    textmark_spike2 = cat(1,textmark_spike2,current_textmark);
    if length(current_textmark) ~= max_events
        
        exit_flag = true;
    else
        start_tick = textmark_spike2(end).m_Time+1;
    end
end


event_index =0;

for loop_index = 1:length(textmark_spike2)
    
    
    current_time = CEDS64TicksToSecs(fhand,textmark_spike2(loop_index).m_Time);
    if current_time>.5
        event_index = event_index+1;
        text_mark_info.markers{event_index} = textmark_spike2(loop_index).m_Data;
        text_mark_info.timestamps(event_index) = current_time;
        
    end
    
    
    
    
end






