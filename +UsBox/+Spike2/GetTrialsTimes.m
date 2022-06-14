function trial_info = GetTrialsTimes(text_mark_info)


%extract textmark strings and times



%extract iv values and stim onset times
parameter_test =  regexp( text_mark_info.text,'T2');
parameter_test = ~cellfun(@isempty,parameter_test);
if sum(parameter_test)==0
    [text_index.names,text_index.extents] =regexp( text_mark_info.text,'T,(?<IV>\S*)','names','tokenextents');
    trial_logical = ~cellfun(@isempty,text_index.names);
    trial_info.iv = struct2cell(cell2mat(text_index.names(trial_logical)));
    
    trial_info.iv =squeeze(cellfun(@str2num,trial_info.iv))';
    
else
    [text_index.names,text_index.extents] =regexp( text_mark_info.text,'T,(?<IV>\S*),T2,(?<IV2>\S*)','names','tokenextents');
    trial_logical = ~cellfun(@isempty,text_index.names);
    trial_info.iv = struct2cell(cell2mat(text_index.names(trial_logical)));
    
    trial_info.iv =squeeze(cellfun(@str2num,trial_info.iv));
    
    
end

trial_info.times = text_mark_info.times(trial_logical);