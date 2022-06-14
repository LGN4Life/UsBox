function CompletedTrials = CalculateCompletedTimes(TrialParameters,ParameterChannels)

completed_trials= TrialParameters.TrialAdvance(:,1)==1;

if sum(completed_trials)>0
    
    
    advance_logical= TrialParameters.TrialAdvance(:,1)==1;
    TrialParameters.TrialAdvance=TrialParameters.TrialAdvance(advance_logical,:);
    CompletedTrials.combo_list = TrialParameters.iv_combo_list;
    for advance_index=1:size(TrialParameters.TrialAdvance,1)
        
        current_iv = TrialParameters.IV_timestamps<TrialParameters.TrialAdvance(advance_index,2);
        [val,id] =min(abs(TrialParameters.IV_timestamps(current_iv)-TrialParameters.TrialAdvance(advance_index,2)));
        
        CompletedTrials.IV(advance_index,1) = TrialParameters.IV(id,1);
        
        CompletedTrials.IV_timestamps(advance_index,1)  = TrialParameters.IV_timestamps(id);
        
        
        
        logical_fixation =TrialParameters.FixationMarkers<CompletedTrials.IV_timestamps(advance_index);
        logical_fixation=TrialParameters.FixationMarkers(logical_fixation);
        if ~isempty(logical_fixation)
            CompletedTrials.Fixation(advance_index,1)=logical_fixation(end);
        else
            CompletedTrials.Fixation(advance_index,1)=nan;
        end
        
        
        [val,id] =min(abs(TrialParameters.StimulusMarkers(:,1)-CompletedTrials.IV_timestamps(advance_index)));
        CurrentStimKey=TrialParameters.StimulusMarkers(id,:);
        
        %find on level change
        [val,id] =min(abs(ParameterChannels.StimulusParameters.timestamps-CurrentStimKey(1)));
        CompletedTrials.Stimulus(advance_index,1)=ParameterChannels.StimulusParameters.timestamps(id);
        %find off level change
        
        [val,id] =min(abs(ParameterChannels.StimulusParameters.timestamps-CurrentStimKey(2)));
        CompletedTrials.Stimulus(advance_index,2)=ParameterChannels.StimulusParameters.timestamps(id);
        
     
        %after each pair of triggers is found, remove up to that point to
        %avoid back fitting to previous trial
        if id<size(ParameterChannels.StimulusParameters.timestamps,1)
            ParameterChannels.StimulusParameters.timestamps = ParameterChannels.StimulusParameters.timestamps(id+1:end,:);
        end
     
        
        
        %   CompletedTrials.Stimulus
        %   pause
        
        
    end
    
else
    CompletedTrials.Stimulus=[];
    CompletedTrials.Fixation=[];
    
end

for index = 1:size(CompletedTrials.Stimulus,1)
    
    if index<size(CompletedTrials.Stimulus,1)
        current_reward = TrialParameters.RewardMarkers> CompletedTrials.Stimulus(index,2) & TrialParameters.RewardMarkers< CompletedTrials.Stimulus(index+1,1);
        
    else
        current_reward = TrialParameters.RewardMarkers> CompletedTrials.Stimulus(index,2);
        
    end
    CompletedTrials.Rewards(index,1:sum(current_reward)) = TrialParameters.RewardMarkers(current_reward);
    
end
if isfield(TrialParameters,'rgb_list')
    CompletedTrials.rgb_list = TrialParameters.rgb_list;
end






