function data = firing_rate(spikes,triggers,IV,TF,bin_number,data)

data.spike_iv = nan(1,length(spikes));
data.spike_trial = nan(1,length(spikes));
data.spike_phase = nan(1,length(spikes));
if length(TF)==1
    TF = repmat(TF,1,length(IV));
end
for index = 1:size(triggers,1)

   current_spikes = spikes(spikes>triggers(index,1) & spikes<triggers(index,2));
   current_spikes = current_spikes - triggers(index,1);
   
   
   trial_duration = triggers(index,2) - triggers(index,1);
   if TF(index)>.1
    [data.TrialCycleHist(index,:),data.CycleHist_X]=AlertTuning.SingleTrialCycleHist(current_spikes,trial_duration,TF(index),bin_number);
    [data.TrialMean(index),data.TrialF1(index),data.TrialF2(index),data.TrialPhase(index)]=AlertTuning.SingleTrialFiringRate(data.TrialCycleHist(index,:),TF(index));
    current_spikes_mod = mod(current_spikes,1/TF(index));
   data.spike_phase(spikes>triggers(index,1) & spikes<triggers(index,2)) = 2*pi*current_spikes_mod*TF(index);
   else
       data.TrialCycleHist(index,1) =nan;
       data.TrialMean(index,1) = length(current_spikes)/trial_duration;
       data.TrialF1(index,1) = nan ;
       data.TrialF2(index,1) = nan ;
       data.TrialPhase(index,1) = nan;
   end
   data.SpikeCount(index) = length(current_spikes);
   if ~isempty(current_spikes)
       data.spike_iv(spikes>triggers(index,1) & spikes<triggers(index,2)) = IV(index);
       data.spike_trial(spikes>triggers(index,1) & spikes<triggers(index,2)) = index;
   end
    
    
    
end

