function coherence = quickie_coherence(FileName)
load(FileName,'data','continuous_recording');

continuous_recording = continuous_recording.FilterData;
continuous_recording = continuous_recording.SubsampleData;
continuous_recording = continuous_recording.Remove60Hz;

trial_types.string = 'CompletedTrials.IV==0';
params.tapers=[3 6];
params.fpass = [2 100];
params.trialave=1;
params.err = [2 .05];

[TrialParameters,CompletedTrials] = TuningData.Alert.TextKeyExtract(data);

trial_duration_limit = 1;
[lfp_by_trial,triggers] = CorticoThalamic.LFPTrialDivision(continuous_recording,data,trial_duration_limit);

lfp_by_trial  =CorticoThalamic.NoiseTrials(lfp_by_trial);
params.Fs = continuous_recording.Fs;

trial_spikes =get_spike_struct(data,triggers);
trial_spike_counts = cellfun(@length,(squeeze(struct2cell(trial_spikes))));

CompletedTrials.noise_trials =  sum(isfinite(lfp_by_trial.y))==0 | trial_spike_counts'<1;

lfp_by_trial.y(~isfinite(lfp_by_trial.y))=0;






current_trials = eval(trial_types.string);

current_trials = current_trials' & ~CompletedTrials.noise_trials;

fscorr = 1;


[coherence]=LFP.coherencycpt(lfp_by_trial.y(:,current_trials),trial_spikes(current_trials),params,fscorr,lfp_by_trial.x);


%parfor loops require specific types of variables. Due
%to this restriction, we can't just calculate ppc with
%two for loops. Instead, create a list of all the pairs
%of phase angles and then loop through that

% create list of angle pairs
pair_ids = 1:size(coherence.phi,2)*size(coherence.phi,2);
[px,py] = meshgrid(1:size(coherence.phi,2));
pair_combos = cat(1,px(pair_ids),py(pair_ids));
%exclude all pairs that are redudant (order of pairs
%does not matter so (2,3) is the same as (3,2).
pair_combos =pair_combos(:,pair_combos(1,:)<pair_combos(2,:));

%Actually, once you create the pair matrix, you don't
%need any loops!

ppc  = cos(coherence.phi(:,pair_combos(1,:))) .* cos(coherence.phi(:,pair_combos(2,:))) +...
    sin(coherence.phi(:,pair_combos(1,:))) .* sin(coherence.phi(:,pair_combos(2,:)));



coherence.ppc_index = nanmean(ppc,2);
figure(1),subplot(1,2,1),plot(coherence.f,coherence.C), axis square
figure(1),subplot(1,2,2),plot(coherence.f,coherence.ppc_index), axis square
end

function  trial_spikes =get_spike_struct(data,triggers)


trial_spikes = struct('spike_times',nan);
trial_spikes(size(triggers,1)).spike_times = nan;


for trial_index = 1:size(triggers,1)
    
    [current_trial_spikes] = CorticoThalamic.SingleTrialSpikes(data.SpikeData.RawSpikeTimes,triggers(trial_index,:));
    
    trial_spikes(trial_index).spike_times = current_trial_spikes-triggers(trial_index,1);
    
    
    
    
    
end

end






        
        
        
        
        
