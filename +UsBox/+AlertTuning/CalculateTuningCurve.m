function tuning_data = CalculateTuningCurve(spikes,triggers,IV,params)

smooth_flag = true;
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
tuning_data.PSTH_X = params.pre_window:params.bin_size:params.trial_duration_limit;

tuning_data = UsBox.AlertTuning.firing_rate(spikes,triggers,IV,TF,cycle_bin_number,tuning_data);
tuning_data = UsBox.AlertTuning.psth(spikes,triggers,tuning_data);

if isfield(params,'iv')
    iv_list = params.iv;
    %when dividing trials into categories, some IV may not be represented. Pass
    %the full parameter list (e.g., iv_list) to prevent a mismatch in tuning
    %curve dimensions
    tuning_data =UsBox.AlertTuning.sort(tuning_data,IV,smooth_flag, iv_list);
else
    tuning_data =UsBox.AlertTuning.sort(tuning_data,IV,smooth_flag);
    
end
