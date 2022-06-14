function tuning_data = CalculateTuningCurve_w_pupil(spikes,triggers,IV,params)


if isfield(params,'TF')
    TF = params.TF;
    
else
    fprintf('No user defined TF, setting TF = 0\n');
     TF = 0;
end

if isfield(params,'cycle_bin_number')
    cycle_bin_number= params.cycle_bin_number;
   
else
    fprintf('No user defined cycle_bin_number, setting cycle_bin_number = 16\n');
    cycle_bin_number = 16;
end
tuning_data.PSTH_X = params.pre_window:params.bin_size:params.max_trial_duration;

tuning_data = AlertTuning.firing_rate(spikes,triggers,TF,cycle_bin_number,tuning_data);
tuning_data = AlertTuning.psth(spikes,triggers,tuning_data);

tuning_data =AlertTuning.sort(tuning_data,IV,smooth_flag);
% tuning_data.IV = IV;
% 
% tuning_data.Stimulus = triggers;

