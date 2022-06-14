function [current_trial_spikes,spike_ids] = SingleTrialSpikes(RawSpikeTimes,StimulusMarkers)
if length(StimulusMarkers)==2
    spike_ids = RawSpikeTimes>StimulusMarkers(:,1) & RawSpikeTimes<=StimulusMarkers(:,2);
    current_trial_spikes =RawSpikeTimes(spike_ids);
    current_trial_spikes=current_trial_spikes-StimulusMarkers(:,1);
else
    spike_ids = RawSpikeTimes>StimulusMarkers(:,1) & RawSpikeTimes<=StimulusMarkers(:,3);
    current_trial_spikes =RawSpikeTimes(spike_ids);
    current_trial_spikes=current_trial_spikes-StimulusMarkers(:,2);
end


%current_trial_spikes = mod(current_trial_spikes,1/TF);





