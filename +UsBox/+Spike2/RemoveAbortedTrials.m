function advanced_trial_times = RemoveAbortedTrials(trial_info,text_mark_info,stimulus)




[advance_index.names,advance_index.extents] =regexp( text_mark_info.text,'(?<advance>+)','names','tokenextents');
advance_logical = ~cellfun(@isempty,advance_index.names);
advance_index.times = text_mark_info.times(advance_logical);

advance_hist_x = [trial_info.times(1:end) inf];
[~,~,advance_trial_ids] = histcounts(advance_index.times,advance_hist_x);
advance_trial_ids= unique(advance_trial_ids);
trial_info.iv = trial_info.iv(:,advance_trial_ids);
trial_iv_times = trial_info.times(advance_trial_ids);
advanced_trial_times = stimulus*nan;
for trial_index = 1:length(trial_iv_times)
    [~,id] = min(abs(trial_iv_times(trial_index) - stimulus(1,:)));
    advanced_trial_times(:,trial_index) = stimulus(:,id);
    
end
