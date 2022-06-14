function [tuning_data, CompletedTrials, AllTrials] = get_trigger_info(data,spike_times,varargin)

if isempty(varargin)
    params.cycle_bin_number = 16;
    params.pre_window = -.5;
    params.bin_size =  0.02;
    params.max_trial_duration = .5;
    
    
    
else
    params = varargin{1};
end


tuning_curves = ["area_","spa_","con_","tem","pd","ori"];


if contains(data.Parameters.FileNames.MatLab,tuning_curves)
    
    
    
    [AllTrials,CompletedTrials] = AlertTuning.TextKeyExtract(data.Parameters);
    
    if contains(data.Parameters.FileNames.MatLab,'tem')
        params.TF = CompletedTrials.IV;
    else
        
        params.TF = str2num(data.Parameters.Stimulus.TemporalFrequency) ;
    end
    
    
    triggers = CompletedTrials.Stimulus;
    tuning_data = AlertTuning.CalculateTuningCurve(spike_times,triggers,CompletedTrials.IV,params);
    
else
    
    tuning_data = [];
    CompletedTrials = [];
    AllTrials = [];
    
end


