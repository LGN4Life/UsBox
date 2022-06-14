function [vfb, held_fixation,valid_fixation_triggers] = valid_fixation_bins(CompletedTrials, continuous_recording)

if length(CompletedTrials.Fixation)>2
    held_fixation = cat(1,-999, CompletedTrials.Fixation(2:end)  - CompletedTrials.Fixation(1:end-1))==0 ;
else
     held_fixation = false(size(CompletedTrials.Stimulus,1),1);
end


valid_fixation_triggers = zeros(1,2);
hf = false;
vp = 1; %vp = valid_period (e.g., valid period of fixation, increment between each period)



for trial_index = 1:size(CompletedTrials.Stimulus,1)-1
    
    if CompletedTrials.OptoState(trial_index,2)==0
        if ~hf
            %if they didn't previously hold fixation, start new period
            valid_fixation_triggers(vp,1) =CompletedTrials.Fixation(trial_index);
        end
        if held_fixation(trial_index+1)
            hf = true;
        else
            hf = false;
            valid_fixation_triggers(vp,2) = CompletedTrials.Stimulus(trial_index,2);
            vp=vp+1;
            
        end
    else
        
        hf = false;
        
    end
    
    
end
if valid_fixation_triggers(end,2) == 0
    
    valid_fixation_triggers(end,2) = CompletedTrials.Stimulus(end,2);
end

m = max(diff(valid_fixation_triggers,[],2));
m = ceil(m+1);
%valid_fixation_triggers = valid_fixation_triggers(valid_fixation_triggers(:,1)+m<continuous_recording.X(end),:);
[lfp] = LFP.TrialDivision(continuous_recording, valid_fixation_triggers, m);

vfb = lfp.trial_bins(:);
vfb = sort(vfb(isfinite(vfb)));
all_bins = 1:length(continuous_recording.X);
vfb = ismember(all_bins,vfb);