function  [lfp_data,triggers] = LFPTrialDivision(continuous_recording,data,trial_duration_limit)
%TriggerMarkers(:,1) = start of data
%TriggerMarkers(:,2) = end of data

trial_duration_limit_bins = floor(trial_duration_limit*continuous_recording.Fs);
[data.Parameters.TrialParameters,data.Parameters.CompletedTrials] = AlertTuning.TextKeyExtract(data);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lfp_data.x = (0:trial_duration_limit_bins)/continuous_recording.Fs;
triggers = data.Parameters.CompletedTrials.Stimulus;
lfp_data.y = nan(length(lfp_data.x),size(triggers,1));







for trial_index = 1:size(triggers,1)

    current_trial_length_bins = (triggers(trial_index,2)-triggers(trial_index,1))*continuous_recording.Fs;
    if current_trial_length_bins>trial_duration_limit_bins
        triggers(trial_index,1)=triggers(trial_index,2) - trial_duration_limit;
        current_trial_length_bins = (triggers(trial_index,2)-triggers(trial_index,1))*continuous_recording.Fs;
    end

    current_bins  = continuous_recording.X> triggers(trial_index,1) & continuous_recording.X<= triggers(trial_index,2);
    
    lfp_data.y(1:sum(current_bins),trial_index) = continuous_recording.Y(current_bins);
    
end




