function PSTH = SingleTrialPSTH(TrialSpikes,PSTH_X,StimulusMarkers, bin_size,TF)

StimulusMarkers = StimulusMarkers-StimulusMarkers(1);



TrialDuration = StimulusMarkers(2)-StimulusMarkers(1);
trial_x=0:bin_size:TrialDuration;
trial_x=trial_x(trial_x>=PSTH_X(1) & trial_x<=PSTH_X(end));



PSTH = nan(length(PSTH_X),1);


trial_psth =histcounts(TrialSpikes,trial_x)/bin_size;
current_bins = find(PSTH_X>=trial_x(1) & PSTH_X<=trial_x(end));

PSTH(current_bins(1):current_bins(1)+length(trial_psth)-1) = trial_psth;
%whos PSTH
%current_bins(1)+length(trial_psth)-1
if length(PSTH)>length(PSTH_X)
    StimulusMarkers

   whos PSTH_X 
   pause
end

 
% pause


