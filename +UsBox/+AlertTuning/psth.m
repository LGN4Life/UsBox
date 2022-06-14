function data = psth(spikes,triggers,data)

pre_window = min(data.PSTH_X);
bin_size = data.PSTH_X(2) - data.PSTH_X(1);
for index = 1:size(triggers,1)
   
   current_spikes = spikes(spikes>triggers(index,1)+pre_window & spikes<triggers(index,2));
   current_spikes = current_spikes - triggers(index,1);
   
   data.TrialPSTH(index,:) = histcounts(current_spikes,data.PSTH_X)/bin_size;
   data.TrialSpikeCount(index) = sum(current_spikes>0);
   
   
   %remove bins where the trial was not as long as the psth_x
   trial_duration = triggers(index,2) - triggers(index,1);
   used_bins = data.PSTH_X(1:end-1)<=trial_duration;
   data.TrialPSTH(index,~used_bins) = nan;
    data.TrialPSTHMean(index) = data.TrialSpikeCount(index)/trial_duration;
    
    
end