function con_ppc = contrast_batch_spike_centered_ppc(data_set,varargin)

window_time = .3;
f = 1:100;


LoopVar = Spike2.StartLoop(data_set,varargin);


cn=0;
all_data.f = f;
pre_window = 1;
TrialDurationMax = 1;
ppc_bs = .02; %bin size for ppc spectrogram
ppc_x = -pre_window:ppc_bs:TrialDurationMax;

for file_index =LoopVar.start_index:LoopVar.end_index
    display(['Reading excel row ' num2str(LoopVar.true_row_index(file_index))])
    [current_excel_line] = Spike2.BuildExcelDataField(LoopVar.column_names,LoopVar.excel_data(file_index,:));
    %     figure(1),clf
    %     figure(2),clf
    %     figure(3),clf
    if current_excel_line.Exclude ==0 & contains(current_excel_line.FileName,'con') & current_excel_line.ContinuousChannel>0
        tic
        
        FileName = Utilities.ConstructFileName(data_set,current_excel_line);
        load(FileName,'data','continuous_recording');
        %data.SpikeData.RawSpikeTimes = data.SpikeData.RawSpikeTimes(1:1000);
        if str2num(data.Parameters.Stimulus.TemporalFrequency) >.1 
            cn=cn+1;
            fs = continuous_recording.Fs;
            tuning_data = AlertTuning;
            tuning_data.TrialDurationMax = TrialDurationMax;
            tuning_data.PSTH_bin_size = .001;
            tuning_data = tuning_data.Calculate(data);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %% calculate c50
            
           response = tuning_data.F1;
            response = response - min(response);
            response = response/max(response);
            contrast = tuning_data.IV;
            
         
            [Param,New_X,New_Y] = HRat_fit_call(contrast,response);
            
            
            
            temp = find(New_Y>.5);
            
            con_ppc.c50(cn) = New_X(temp(1));
            
            low_trials = tuning_data.TrialIV<=con_ppc.c50(cn);
            high_trials = tuning_data.TrialIV>con_ppc.c50(cn);
            
  
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%
            

            [TrialParameters,CompletedTrials] = TuningData.Alert.TextKeyExtract(data);
            
            %% calculate spike_iv tp divide the individual spike centered LFPs into stim based categories
            
            
            
            TimeRange = eval(current_excel_line.TimeRange);
            good_trials = CompletedTrials.Stimulus(:,1)>TimeRange(:,1) & CompletedTrials.Stimulus(:,2)<TimeRange(:,2);
            CompletedTrials.Stimulus(~good_trials,:) = nan;
            current_triggers = CompletedTrials.Stimulus;
            current_triggers(:,1) = current_triggers(:,1)-pre_window;
            spike_iv = AlertTuning.calculate_spike_iv(data.SpikeData.RawSpikeTimes,CompletedTrials.IV,current_triggers);
            if max(CompletedTrials.OptoTriggers)>0
                spike_opto = AlertTuning.calculate_spike_iv(data.SpikeData.RawSpikeTimes,CompletedTrials.OptoState(:,2),current_triggers);
            else
                spike_opto = zeros(1,length(spike_iv));
            end
            
            
            %% divide lfps into trial snippets
            
            lfp = LFP.fast_spike_centered_lfp(data.SpikeData.RawSpikeTimes,continuous_recording,window_time);
            
            [lfp, noise_trials]  = AlertTuning.NoiseTrials(lfp);
            
            % when lfp data snippets are extracted they are not zero padded
            % because this interfers with the calculation of noise. Instead
            % they are padded with nan. Convert the nan padding to zeros
            lfp(~isfinite(lfp)) = zeros;
            lfp(:,noise_trials) = nan;
            
            %%
            %to create a spectrogram assign each spike a psth bin
            spike_time_bin = nan(1,length(data.SpikeData.RawSpikeTimes));
            for trial_index = 1:size(CompletedTrials.Stimulus,1)
                current_spikes_id =  find(data.SpikeData.RawSpikeTimes>CompletedTrials.Stimulus(trial_index,1) - pre_window & ...
                    data.SpikeData.RawSpikeTimes<CompletedTrials.Stimulus(trial_index,2));
                current_spike_times =data.SpikeData.RawSpikeTimes(current_spikes_id) - CompletedTrials.Stimulus(trial_index,1);
                [~,~,current_bins] = histcounts(current_spike_times,ppc_x);
                spike_time_bin(current_spikes_id) = current_bins;
                
            end
            %%
            %calculate spike_psth for spike powewr spectrum
            
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
            
            low_spikes = spike_iv<=con_ppc.c50(cn);
            high_spikes = spike_iv>con_ppc.c50(cn);
            
            %%
            %calculate ps and ppc
            
            con_ppc.f = f;
            
            %ps for spike triggered LFP
            ps_lfp_all = LFP.custom_fft(lfp,f,fs);
            ps_lfp_low = LFP.custom_fft(lfp(:,low_spikes & spike_opto==0 & ~noise_trials),f,fs);
            ps_lfp_high = LFP.custom_fft(lfp(:,high_spikes & spike_opto==0 & ~noise_trials),f,fs);
            
            con_ppc.ps_lfp_low(cn,:) = nanmean(abs(ps_lfp_low),2).^2;
            con_ppc.ps_lfp_high(cn,:) = nanmean(abs(ps_lfp_high),2).^2;
            
            phase_angles_low = angle(ps_lfp_low);
            con_ppc.ppc_low(cn,:) = LFP.ppc(phase_angles_low);
            
            phase_angles_high = angle(ps_lfp_high);
            con_ppc.ppc_high(cn,:) = LFP.ppc(phase_angles_high);
            
            figure(2),plot(f,con_ppc.ppc_low(cn,:),'b')
            hold on
            figure(2),plot(f,con_ppc.ppc_high(cn,:),'r')
            hold off
            
            figure(3),plot(f,nanmean(con_ppc.ppc_low,1),'b')
            hold on
            figure(3),plot(f,nanmean(con_ppc.ppc_high,1),'r')
            hold off
            
            
            
            
            
            
            ps_spike_low = LFP.custom_fft(spike_psth(low_trials,:)',f,fs_spiking);
            ps_spike_high = LFP.custom_fft(spike_psth(high_trials,:)',f,fs_spiking);
            
            
            
            con_ppc.ps_spike_low(cn,:) = nanmean(abs(ps_spike_low),2).^2;
            con_ppc.ps_spike_high(cn,:) = nanmean(abs(ps_spike_high),2).^2;
            
            %%
            %spectrogram for ppc
            con_ppc.spectrogram_time = ppc_x;
        
            for time_index =1:length(ppc_x)
                
                current_spikes = spike_time_bin>= time_index-1 & spike_time_bin<= time_index+1 & low_spikes;
                phase_angles_low = angle(ps_lfp_all(:,current_spikes));
                con_ppc.ppc_spectrogram_low(cn,:,time_index) = LFP.ppc(phase_angles_low);
                
                
                current_spikes = spike_time_bin>= time_index-1 & spike_time_bin<= time_index+1 & high_spikes;
                phase_angles_high = angle(ps_lfp_all(:,current_spikes));
                con_ppc.ppc_spectrogram_high(cn,:,time_index) = LFP.ppc(phase_angles_high);
                
                
                
                
            end
            toc
            figure(1),imagesc(squeeze( con_ppc.ppc_spectrogram_high(cn,:,:)))
            figure(10),imagesc(squeeze(nanmean(con_ppc.ppc_spectrogram_high)))
            %save(FileName,'con_ppc','-append')
            pause(1)
        end
    end
    
    
end


