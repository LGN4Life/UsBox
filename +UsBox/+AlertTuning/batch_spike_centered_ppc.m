function all_data = batch_spike_centered_ppc(data_set, cell_criteria,trial_types,window_time,f,varargin)




LoopVar = Spike2.StartLoop(data_set,varargin);


cell_num = 0;
all_data.f = f;
pre_window = 1;

for file_index =LoopVar.start_index:LoopVar.end_index
    display(['Reading excel row ' num2str(LoopVar.true_row_index(file_index))])
    [current_excel_line] = Spike2.BuildExcelDataField(LoopVar.column_names,LoopVar.excel_data(file_index,:));
%     figure(1),clf
%     figure(2),clf
%     figure(3),clf
    if eval(cell_criteria)
        
        FileName = Utilities.ConstructFileName(data_set,current_excel_line);
        load(FileName,'data','continuous_recording','FitData');
        fs = continuous_recording.Fs;
        tuning_data = AlertTuning;
        tuning_data.TrialDurationMax = 1.0;
        tuning_data.PSTH_bin_size = .001;
        tuning_data = tuning_data.Calculate(data);
        
        x = -1*pre_window:1/continuous_recording.Fs:tuning_data.TrialDurationMax;
        
        [TrialParameters,CompletedTrials] = TuningData.Alert.TextKeyExtract(data);
        
        
        figure(1),plot(tuning_data.IV,tuning_data.F1,'o-')
        hold on
        figure(1),plot(tuning_data.IV,tuning_data.Mean,'+-')
        hold off
        
        figure(2),plot(CompletedTrials.Stimulus(:,1),tuning_data.TrialF1)
        for trial_index = 1:length(tuning_data.TrialIV)
            current_trials = tuning_data.TrialIV == tuning_data.TrialIV(trial_index);
            m = nanmean( tuning_data.TrialF1(current_trials));
            e = nanstd( tuning_data.TrialF1(current_trials));
            TrialF1_z(trial_index) = (tuning_data.TrialF1(trial_index) - m )/e;
            
        end
        
        figure(3),plot(CompletedTrials.Stimulus(:,1),TrialF1_z,'o')
        
        
        %calculate spike_iv tp divide the individual spike centered LFPs
        %into stim based categories
        TimeRange = eval(current_excel_line.TimeRange);
        good_trials = CompletedTrials.Stimulus(:,1)>TimeRange(:,1) & CompletedTrials.Stimulus(:,2)<TimeRange(:,2);
        CompletedTrials.Stimulus(~good_trials,:) = nan;
        spike_iv = AlertTuning.calculate_spike_iv(data.SpikeData.RawSpikeTimes,CompletedTrials.IV,CompletedTrials.Stimulus);
        if max(CompletedTrials.OptoTriggers)>0
            spike_opto = AlertTuning.calculate_spike_iv(data.SpikeData.RawSpikeTimes,CompletedTrials.OptoState(:,2),CompletedTrials.OptoTriggers);
        else
            spike_opto = zeros(1,length(spike_iv));
        end
        
        lfp = LFP.spike_centered_lfp(data.SpikeData.RawSpikeTimes,continuous_recording,window_time);
        
        [lfp, noise_trials]  = AlertTuning.NoiseTrials(lfp);
        
        % when lfp data snippets are extracted they are not zero padded
        % because this interfers with the calculation of noise. Instead
        % they are padded with nan. Convert the nan padding to zeros
        lfp(~isfinite(lfp)) = zeros;
        lfp(:,noise_trials) = nan;
        
        %to create a spectrogram assign each spike a psth bin
        spike_time_bin = nan(1,size(CompletedTrials.Stimulus,1));
        for trial_index = 1:size(CompletedTrials.Stimulus,1)
           current_spikes_id =  find(data.SpikeData.RawSpikeTimes>CompletedTrials.Stimulus(trial_index,1) - pre_window & ...
               data.SpikeData.RawSpikeTimes<CompletedTrials.Stimulus(trial_index,2));
           current_spike_times =data.SpikeData.RawSpikeTimes(current_spikes_id) - CompletedTrials.Stimulus(trial_index,1);
           [~,~,current_bins] = histcounts(current_spike_times,x);
            spike_time_bin(current_spikes_id) = current_bins;
            
        end

        spike_bs =tuning_data.PSTH_X(2) - tuning_data.PSTH_X(1);
        %         test_wf = sin(2*pi*4*(spike_bs:spike_bs:1));
        %         test_wf = repmat(test_wf,size(tuning_data.TrialPSTH,1),1);
        clear spike_psth
        rs = 1;%ceil(spike_bs/.001);
        tuning_data.TrialPSTH(~isfinite(tuning_data.TrialPSTH)) = 0;
        for trial_index = 1:size(tuning_data.TrialPSTH,1)
            spike_psth(trial_index,:) = interp(tuning_data.TrialPSTH(trial_index,:),rs);
            
            
        end
%         figure(10),plot(nanmean(spike_psth))
        fs_spiking = 1/(spike_bs/rs);
       
        cell_num=cell_num+1;
         figure(4),cla, hold on
        for type_index = 1:length(trial_types.string)
            current_trials = eval(trial_types.string{type_index});
            current_trials = current_trials & ~noise_trials;
            
       
            
            current_trials = current_trials & spike_opto==0;
            temp = find(current_trials);
            trial_count(type_index) = sum(current_trials);
            
  
            ppc_sc{type_index}.ps_lfp = LFP.custom_fft(lfp(:,current_trials),f,fs);
            
            ppc_sc{type_index}.f = f;
            
            current_trials = eval(trial_types.string2{type_index});
            %current_trials = current_trials & ~noise_trials;
            ppc_sc{type_index}.ps_spike = LFP.custom_fft(spike_psth(current_trials,:)',f,fs_spiking);
            phase_angles = angle(ppc_sc{type_index}.ps_lfp);
            ppc_sc{type_index}.ppc = LFP.ppc(phase_angles);
            
            %calculate ppc 
            all_data.ps_lfp(type_index,:,cell_num) = nanmean(abs(ppc_sc{type_index}.ps_lfp),2).^2;
            all_data.ps_spike(type_index,:,cell_num) = nanmean(abs(ppc_sc{type_index}.ps_spike),2).^2;
            
            all_data.ppc(type_index,:,cell_num) = ppc_sc{type_index}.ppc;
            all_data.spike_count(type_index,cell_num) = trial_count(type_index);
            figure(4),plot(f,all_data.ps_lfp(type_index,:,cell_num) )
            hold on
%             figure(2),plot(f,all_data.ppc(type_index,:,cell_num) )
%             hold on
%             figure(3),plot(f,all_data.ps_spike(type_index,:,cell_num) )
%             hold on
           
%             for ti = 1:size(ppc_sc{type_index}.ps_lfp,2)
%                 ti
%                 figure(4),plot(abs(ppc_sc{type_index}.ps_lfp(:,ti)))
%                 figure(5),plot(lfp(:,temp(ti)))
%                 set(gca,'ylim',[-.2 .2])
%            
%             end
            
            
       
        end
        
        
        
        all_data.FileName{cell_num} = FileName;
        all_data.Animal{cell_num} = data.Parameters.ExcelData.AnimalName;
         all_data.MP{cell_num} = data.Parameters.ExcelData.CellType;   
        save(FileName,'ppc_sc','-append');
        
        clear ft
    end
    
    
end


