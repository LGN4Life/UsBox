function area_dog(data_set,varargin)



if length(varargin)>=1
    start_index = varargin{1};
else
    start_index = 1;
end

if length(varargin)>=2
    end_index = varargin{2};
else
    
    end_index = size(data_set,1);
end

matlab_directory = 'D:\AwakeData\Matlab\';
trial_duration_limit =1;
pre_window = 0;
f = 4:100;
LFPMat.f = f;
fn = 0;

window_time = .3;

for file_index = start_index:end_index
    
    current_folder = [matlab_directory data_set.FileName{file_index} '\'];
    fprintf(['File: ' data_set.FileName{file_index} '. File Index: ' num2str(file_index)  '\n'])
    
    if data_set.SpikeChannel(file_index)>0 & data_set.Exclude(file_index)==0 & contains(data_set.FileName{file_index},'area')
        
        spike_file = ['spike_channel_' num2str(data_set.SpikeChannel(file_index)) '_' num2str(data_set.WaveMark(file_index))];
        continuous_file = ['continuous_channel_' num2str(data_set.ContinuousChannel(file_index))];
        
        load([current_folder spike_file])
        
        load([current_folder 'parameters'])
        
        TimeRange = eval(data_set.TimeRange{file_index});
        
        triggers =  CompletedTrials.Stimulus;
        
        params.cycle_bin_number = 16;
        params.pre_window = 0;
        params.bin_size =  0.01;
        params.max_trial_duration = .5;
        params.TF = str2double(parameters.Stimulus.TemporalFrequency);
        if isfield(CompletedTrials,'Stimulus')
            if isempty(CompletedTrials.Stimulus)
                CompletedTrials=[];
            end
        end
        if ~isempty(CompletedTrials) & length(spike_times)>0
            
            %%
            
            control_trials = CompletedTrials.OptoState(:,2) == 0 & CompletedTrials.Stimulus(:,1)>TimeRange(1) & ...
                CompletedTrials.Stimulus(:,2)<TimeRange(2);
            
            
            if contains(data_set.FileName{file_index},'boxodonuts_area_con')
                
                %find large area
                large_area = max(CompletedTrials.combo_list(:,1));
                large_combos = find(CompletedTrials.combo_list(:,1)== large_area);
                large_iv = ismember(CompletedTrials.IV,large_combos);
                CompletedTrials.IV(~large_iv) = nan;
                unique_iv = unique(CompletedTrials.IV(isfinite(CompletedTrials.IV)));
                CompletedTrials.IV(large_iv) = CompletedTrials.combo_list(CompletedTrials.IV(large_iv),2);
            
                
            end
            
             if contains(data_set.FileName{file_index},'boxodonuts_spa_con')
                
                %find SF near 1 cycle/deg
                large_area = min(CompletedTrials.combo_list(:,1)-1);
                large_combos = find(CompletedTrials.combo_list(:,1)-1== large_area);
                large_iv = ismember(CompletedTrials.IV,large_combos);
                CompletedTrials.IV(~large_iv) = nan;
                unique_iv = unique(CompletedTrials.IV(isfinite(CompletedTrials.IV)));
                CompletedTrials.IV(large_iv) = CompletedTrials.combo_list(CompletedTrials.IV(large_iv),2);
                
            end
            
            if contains(data_set.FileName{file_index},'boxodonuts_con_area') 
                
                
                %find large area
                large_area = max(CompletedTrials.combo_list(:,2));
                large_combos = find(CompletedTrials.combo_list(:,2)== large_area);
                large_iv = ismember(CompletedTrials.IV,large_combos);
                CompletedTrials.IV(~large_iv) = nan;
                unique_iv = unique(CompletedTrials.IV(isfinite(CompletedTrials.IV)));
                CompletedTrials.IV(large_iv) = CompletedTrials.combo_list(CompletedTrials.IV(large_iv),1);
         
            end
            
             if contains(data_set.FileName{file_index},'boxodonuts_con_spa')
                
                 %find SF near 1 cycle/deg
                large_area = min(CompletedTrials.combo_list(:,2)-1);
                large_combos = find(CompletedTrials.combo_list(:,2)-1== large_area);
                large_iv = ismember(CompletedTrials.IV,large_combos);
                CompletedTrials.IV(~large_iv) = nan;
                unique_iv = unique(CompletedTrials.IV(isfinite(CompletedTrials.IV)));
                CompletedTrials.IV(large_iv) = CompletedTrials.combo_list(CompletedTrials.IV(large_iv),1);
                
            end
            
            tuning_data = AlertTuning.CalculateTuningCurve(spike_times,triggers(control_trials,:),CompletedTrials.IV(control_trials),params);
    
            if length(tuning_data.IV)>3
                if params.TF>.1
                    response = tuning_data.F1;
                else
                    response = tuning_data.Mean;
                end
                response = response - min(response);
                response = response/max(response);
                area = tuning_data.IV;
                spon = min(response);
                
                [fit_data.param,fit_data.New_X,fit_data.New_Y]  = LGN_LFP.area_dog_single(response,area,spon);
                temp = find(fit_data.New_Y<max(fit_data.New_Y));
                [val,id] = max(fit_data.New_Y);
                temp = find(temp<=id);
                if isempty(temp)
                    fit_data.peak =nan;
                else
                    fit_data.peak = fit_data.New_X(temp(end));
                end
                
                
                
            else
                
                fit_data=[];
                
                
            end
        else
            tuning_data=[];
            fit_data = [];
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if exist([current_folder 'area.mat'],'file')
            save([current_folder 'area.mat'],'tuning_data','fit_data', '-append')
        else
            save([current_folder 'area.mat'],'tuning_data','fit_data')
        end
        

        
    end
    
    
    
end

