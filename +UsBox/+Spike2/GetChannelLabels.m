function [channel_info] = GetChannelLabels(fhand)

%load channel info from spike2 file
%list of channel titles is located in ChannelIndexSpike2Data.ChannelInfo(:).label
channel_info=[];

[ num_chan] = CEDS64MaxChan( fhand );

index=0;
for channel_index = 1:num_chan
    
    [ iOk , channel_title ] = CEDS64ChanTitle( fhand, channel_index);
    
    
    if iOk==0
        %untitled chnnels mostly do not have data
        if ~strcmp(channel_title,'untitled')
            
            index=index+1;
            channel_info.names{index} = channel_title;
            channel_info.type{index}= CEDS64ChanType( fhand, channel_index );
            channel_info.number(index) = channel_index;
        else
            if channel_index==30
                %for some alert files, the textmarker channel (ch30) was
                %not titled.
                index=index+1;
                channel_info.names{index} = 'TextMark';
                channel_info.type{index}= CEDS64ChanType( fhand, channel_index );
                channel_info.number(index) = channel_index;
            end
        end
        
    end
    
end






