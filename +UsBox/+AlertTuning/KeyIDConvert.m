function TrialParameters = KeyIDConvert(KeyID,TextID)

TrialParameters.FixationMarkers =KeyID.FixationOn.timestamps;
TrialParameters.StimulusMarkers =KeyID.StimTrial.timestamps;


TrialParameters.RewardMarkers =KeyID.Reward.timestamps;

%current_reward = 


tempstruct=squeeze(struct2cell(TextID.StimOn.FieldInfo));

TrialParameters.IV(:,1) = cellfun(@str2num,tempstruct)';
TrialParameters.IV_timestamps = TextID.StimOn.timestamps;

if ~isempty(TextID.SecondIV_Value.FieldInfo)
    tempstruct=squeeze(struct2cell(TextID.SecondIV_Value.FieldInfo));
    TrialParameters.IV(:,2) = cellfun(@str2num,tempstruct)';
    iv_1 = unique(TrialParameters.IV(:,1));
    iv_2 = unique(TrialParameters.IV(:,2));
    unique_combo=0;
    combo_list = ones(length(TrialParameters.IV(:,1)),1);
    for index_1 = 1:length(iv_1)
        for index_2 = 1:length(iv_2)
            unique_combo=unique_combo+1;
            current_trials = TrialParameters.IV(:,1) == iv_1(index_1) & TrialParameters.IV(:,2) == iv_2(index_2);
            combo_list(current_trials) = unique_combo;
            TrialParameters.iv_combo_list(unique_combo,:) = [iv_1(index_1) iv_2(index_2)];
        end
        
    end
    TrialParameters.IV = combo_list;
    
else
    
    
    TrialParameters.iv_combo_list = [];
    
end


trial_advance = struct2cell(TextID.TrialAdvance.FieldInfo);
trial_advance = regexp(trial_advance,'+');
completed_trials = ~cellfun(@isempty,trial_advance);

TrialParameters.TrialAdvance(completed_trials,1)=1;
TrialParameters.TrialAdvance(~completed_trials,1)=0;
TrialParameters.TrialAdvance(:,2) = TextID.TrialAdvance.timestamps;


