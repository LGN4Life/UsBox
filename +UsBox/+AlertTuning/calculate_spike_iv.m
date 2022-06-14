function [spike_iv, spike_trial_num] = calculate_spike_iv(spikes,iv,triggers)



spike_iv = nan(1,length(spikes));
spike_trial_num = nan(1,length(spikes));


for index = 1:size(triggers,1)
    current_spikes = spikes >= triggers(index,1) & spikes <= triggers(index,2) ;
    
    spike_iv(current_spikes) = iv(index);
    spike_trial_num(current_spikes) = index;
    
    
end

