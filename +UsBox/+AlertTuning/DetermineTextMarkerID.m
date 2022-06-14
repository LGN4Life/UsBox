function [TextID,KeyID] = DetermineTextMarkerID(ParameterChannels,Requested_StringArray)

%this scipt takes in a series of requested fields to calculate
%KeyID output is based on Requested_StringArray.key_field. 
%Standard is: KeyID.FixationOn,KeyID.StimTrial, KeyID.OptoState, KeyID.Reward



%exclude text markers at begining of file that confuse analysis
temp = ParameterChannels.TextParameters.timestamps>.2;
ParameterChannels.TextParameters.timestamps=ParameterChannels.TextParameters.timestamps(temp);
ParameterChannels.TextParameters.markers = ParameterChannels.TextParameters.markers(temp);


KeyID=[];

text_markers=ParameterChannels.TextParameters.markers;


key_markers=cellfun(@char,ParameterChannels.KeyboardParameters.markers);

for RequestIndex =1:length(Requested_StringArray.key_string)
% Requested_StringArray.key_string{RequestIndex}



    [key_index.names,key_index.extents] = regexp(key_markers,Requested_StringArray.key_string{RequestIndex},'names','tokenextents');
   

    key_index.extents = cell2mat(key_index.extents');
  
    if ~isempty(key_index.extents)
        key_index.extents= key_index.extents(:,1);
        KeyID.(Requested_StringArray.key_field{RequestIndex}).fieldnames = fields(key_index.names);

        %each token has a name that will be used to identify the data in each column
        FieldNumber = length(KeyID.(Requested_StringArray.key_field{RequestIndex}).fieldnames);
        key_index.start = reshape(key_index.extents,FieldNumber,length(key_index.extents)/FieldNumber)';
        KeyID.(Requested_StringArray.key_field{RequestIndex}).timestamps = ParameterChannels.KeyboardParameters.timestamps(key_index.start);
        KeyID.(Requested_StringArray.key_field{RequestIndex}).value = key_markers(key_index.start);
       
    else
        %empty, do nothing
        KeyID.(Requested_StringArray.key_field{RequestIndex}).value=[];
        KeyID.(Requested_StringArray.key_field{RequestIndex}).timestamps=[];
    end
% KeyID
% pause

end

%sort the trial times
%for all completed trials KeyID.CompletedTrials has the following times:
%[FixOn StimOn StimOff Reward ClearS Advance]
%need to find time of stim change by searching for sample text "Contrast Change, Level <#>, Attend <condition>"

for RequestIndex =1:length(Requested_StringArray.string)

    [text_index.names,text_index.extents] = regexp(text_markers,Requested_StringArray.string{RequestIndex},'names','tokenextents');

    text_index.line =~cellfun(@isempty,text_index.extents);
    text_index.times = ParameterChannels.TextParameters.timestamps(text_index.line);
  
    FieldInfo = text_index.names(text_index.line);



  % save('FieldInfo','FieldInfo')

    TextID.(Requested_StringArray.field{RequestIndex}).FieldInfo=cell2mat(FieldInfo);
    [TextID.(Requested_StringArray.field{RequestIndex}).timestamps]=ParameterChannels.TextParameters.timestamps(text_index.line);



end












