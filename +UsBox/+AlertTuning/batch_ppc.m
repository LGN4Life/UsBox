function all_data = batch_ppc(data_set, cell_criteria,trial_types,params,varargin)


fscorr =  1; % variable for error calc in coherence
trial_duration_limit = 2;

LoopVar = Spike2.StartLoop(data_set,varargin);
zero_column = 2;

cell_num = 0;
for file_index =LoopVar.start_index:LoopVar.end_index
    display(['Reading excel row ' num2str(LoopVar.true_row_index(file_index))])
    [current_excel_line] = Spike2.BuildExcelDataField(LoopVar.column_names,LoopVar.excel_data(file_index,:));

    if eval(cell_criteria)
        
        FileName = Utilities.ConstructFileName(data_set,current_excel_line);
        load(FileName,'data','continuous_recording','FitData');
        
        tuning_data = AlertTuning;
      
        tuning_data = tuning_data.Calculate(data);
        
        
        
        [TrialParameters,CompletedTrials] = TuningData.Alert.TextKeyExtract(data);
        
        spike_iv = AlertTuning.calculate_spike_iv(data.SpikeData.RawSpikeTimes,CompletedTrials.IV,CompletedTrials.Stimulus);
        
        
        
        
        if ~isempty(CompletedTrials.combo_list)
            high_con = CompletedTrials.combo_list(:,2) >=50;
            CompletedTrials.IV(~high_con)=nan;
            
        end
        TimeRange = eval(current_excel_line.TimeRange);
        
        [lfp_by_trial,triggers] = CorticoThalamic.LFPTrialDivision(continuous_recording,data,trial_duration_limit);
        
        lfp_by_trial  =CorticoThalamic.NoiseTrials(lfp_by_trial);
        params.Fs = continuous_recording.Fs;

        trial_spikes =get_spike_struct(data,triggers);
        trial_spike_counts = cellfun(@length,(squeeze(struct2cell(trial_spikes))));
        
        CompletedTrials.noise_trials =  sum(isfinite(lfp_by_trial.y))==0 | trial_spike_counts'<1;
        
        lfp_by_trial.y(~isfinite(lfp_by_trial.y))=0;
        
        

        
        
        ppc_index =[];
        exclude = [true true];
        for type_index = 1:length(trial_types.string)
            current_trials = eval(trial_types.string{type_index});
            
            current_trials = current_trials' & ~CompletedTrials.noise_trials;
            trial_count(type_index) = sum(current_trials);
            if ~exist('fscorr','var')
                
                fscorr = 1;
            end
            
            if sum(current_trials)>2
                exclude(type_index) = false;
                [coherence{type_index}]=LFP.coherencycpt(lfp_by_trial.y(:,current_trials),trial_spikes(current_trials),params,fscorr,lfp_by_trial.x);
    
                
                %parfor loops require specific types of variables. Due
                %to this restriction, we can't just calculate ppc with
                %two for loops. Instead, create a list of all the pairs
                %of phase angles and then loop through that
                
                % create list of angle pairs
                pair_ids = 1:size(coherence{type_index}.phi,2)*size(coherence{type_index}.phi,2);
        
                [px,py] = meshgrid(1:size(coherence{type_index}.phi,2));
                pair_combos = cat(1,px(pair_ids),py(pair_ids));
                %exclude all pairs that are redudant (order of pairs
                %does not matter so (2,3) is the same as (3,2).
                pair_combos =pair_combos(:,pair_combos(1,:)<pair_combos(2,:));
                
                %Actually, once you create the pair matrix, you don't
                %need any loops!
                
                ppc  = cos(coherence{type_index}.phi(:,pair_combos(1,:))) .* cos(coherence{type_index}.phi(:,pair_combos(2,:))) +...
                    sin(coherence{type_index}.phi(:,pair_combos(1,:))) .* sin(coherence{type_index}.phi(:,pair_combos(2,:)));
                
                
                N = size(ppc,2);
                ppc_index(type_index,:) = nanmean(ppc,2);
                
                
                
                
                
                
                
                
                
                
                
            else
                
                
            end
            
            
        end
        if sum(exclude)==0
            figure(1),plot(coherence{type_index}.f,ppc_index(1,:))
            hold on
            figure(1),plot(coherence{type_index}.f,ppc_index(2,:))
            hold off
            trial_count
            cell_num=cell_num+1;
            all_data.ppc(cell_num,:,:) =  ppc_index;
            all_data.FileName{cell_num} = FileName;
            all_data.LFP_PS(cell_num,1,:) = nanmean(coherence{1}.S1,2);
            all_data.LFP_PS(cell_num,2,:) = nanmean(coherence{2}.S1,2);
            all_data.Spike_PS(cell_num,1,:) = nanmean(coherence{1}.S2,2);
            all_data.Spike_PS(cell_num,2,:) = nanmean(coherence{2}.S2,2);
            all_data.f = coherence{1}.f;
     
        end
        
        
        
        
        save(FileName,'ppc_index','tuning_data','coherence','-append');
        
        clear CoherenceMat
    end
    
    
end

end


function  trial_spikes =get_spike_struct(data,triggers)


trial_spikes = struct('spike_times',nan);
trial_spikes(size(triggers,1)).spike_times = nan;


for trial_index = 1:size(triggers,1)
    
    [current_trial_spikes] = CorticoThalamic.SingleTrialSpikes(data.SpikeData.RawSpikeTimes,triggers(trial_index,:));
    
    trial_spikes(trial_index).spike_times = current_trial_spikes-triggers(trial_index,1);
    
    
    
    
    
end

end