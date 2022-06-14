function [data] = LoadParameterChannels(fhand,data,ExcelData)

%load channel info from spike2 file
%list of channel titles is located in ChannelIndexSpike2Data.ChannelInfo(:).label


[ num_chan] = CEDS64MaxChan( fhand );

index=0;
for channel_index = 1:num_chan

    [ iOk , channel_title ] = CEDS64ChanTitle( fhand, channel_index);
   
  
    if iOk==0 
        %untitled chnnels are mostly do not have data
        if ~strcmp(channel_title,'untitled')
           
            index=index+1;
            channel_info(index).names = channel_title;
             channel_info(index).type= CEDS64ChanType( fhand, channel_index );
        else
            if channel_index==30
                %for some alert files, the textmarker channel (ch30) was
                %was not titled.  
                index=index+1;
                channel_info(index).names = 'TextChannel';
                channel_info(index).type= CEDS64ChanType( fhand, channel_index );
            end
        end

    end
    
end
    %
temp_cell_array = struct2cell(channel_info);
ChannelNames = temp_cell_array(1,:);
%[ iType ] = CEDS64ChanType( fhand, iChan )
%[ iChan ] = CEDS64GetFreeChan( fhand )
%[ iChans ] = CEDS64MaxChan( fhand )
%[ i64Time ] = CEDS64MaxTime( fhand )
%[ iRead, vi64T, iLevel ] = CEDS64ReadLevels( fhand, iChan, iN, i64From{,
%i64UpTo} )




for StringIndex=1:length(ExcelData.RequestedColumns_ParameterChannels.string)
    
    
    MatchIndex = ~cellfun(@isempty,regexp(ChannelNames,ExcelData.RequestedColumns_ParameterChannels.string{StringIndex}));
    
    %     MatchIndex = find(strcmp(ExcelData.RequestedColumns_ParameterChannels,Spike2Data.ChannelInfo(ChannelIndex).label)...
    %         & ExcelData.RequestedColumns_ParameterTypes== Spike2Data.ChannelInfo(ChannelIndex).type);

    
    if sum(MatchIndex)>0
       
       
 
        if channel_info(MatchIndex).type==ExcelData.RequestedColumns_ParameterChannels.types(StringIndex)
            ParameterData= Preprocessing.smr_read_channel(data.Parameters.FileNames.ParameterChannels, Spike2Data.ChannelInfo(MatchIndex).index);
            
            if ExcelData.RequestedColumns_ParameterChannels.types(StringIndex) ==5
                if isempty(ParameterData.markers)==0
                    ParameterChannels.(ExcelData.DataStructFields{StringIndex}).markers = ParameterData.markers(1,:)';
                    ParameterChannels.(ExcelData.DataStructFields{StringIndex}).timestamps = ParameterData.timestamps;
                else
                    ParameterChannels.(ExcelData.DataStructFields{StringIndex}).markers =[];
                    ParameterChannels.(ExcelData.DataStructFields{StringIndex}).timestamps =[];
                end
                
            elseif ExcelData.RequestedColumns_ParameterChannels.types(StringIndex) ==8
                if sum(MatchIndex)>1
                    m = find(MatchIndex);
                    for match_index = 1:length(m)
                        if Spike2Data.ChannelInfo(m(match_index)).index==30
                            
                            %Spike2Data.ChannelInfo(m(match_index)).index
                            ParameterData= Preprocessing.smr_read_channel(data.Parameters.FileNames.ParameterChannels, Spike2Data.ChannelInfo(m(match_index)).index);
                            
                        end
                        
                    end
                    
                end
          
                ParameterChannels.(ExcelData.DataStructFields{StringIndex}).markers = ParameterData.text';
                ParameterChannels.(ExcelData.DataStructFields{StringIndex}).timestamps = ParameterData.timestamps';
            elseif ExcelData.RequestedColumns_ParameterChannels.types(StringIndex) ==4
                ParameterChannels.(ExcelData.DataStructFields{StringIndex}).timestamps = ParameterData;
            elseif ExcelData.RequestedColumns_ParameterChannels.types(StringIndex) ==1
                
                
                ParameterChannels.(ExcelData.DataStructFields{StringIndex}).value = ParameterData.data;
                ParameterChannels.(ExcelData.DataStructFields{StringIndex}).sampling_rate = ParameterData.sampling_rate;
                
            end
            
        end
    end
    
end

