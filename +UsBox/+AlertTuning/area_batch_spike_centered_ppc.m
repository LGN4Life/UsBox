function area_ppc = area_batch_spike_centered_ppc(data_set,varargin)

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
    if current_excel_line.Exclude ==0 & contains(current_excel_line.FileName,'area') & current_excel_line.ContinuousChannel>0
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
            
            %% calculate peak diameter
            
            response = tuning_data.F1;
            response = response/max(response);
            area = tuning_data.IV;
            
            %center amp
            fit_lim.ic(1) = 1;
            fit_lim.lb(1) = .1;
            fit_lim.ub(1) = 20;
            %surround amp
            fit_lim.ic(2) = 0;
            fit_lim.lb(2) = 0;
            fit_lim.ub(2) = 20;
            %center sigma
            fit_lim.ic(3) = .5;
            fit_lim.lb(3) = .01;
            fit_lim.ub(3) = 1;
            %surround sigma
            fit_lim.ic(4) = .5;
            fit_lim.lb(4) = .001;
            fit_lim.ub(4) =10;
            %blank
            fit_lim.ic(5) = 0;
            fit_lim.lb(5) = 0;
            fit_lim.ub(5) = 1;
            
            
            
            [Param,New_X,New_Y,err] = RF.dog_area_1D_single(response,area,fit_lim);
            
            %             figure(1),plot(area,response,'o')
            %             hold on
            %             plot(New_X,New_Y,'--k')
            %             hold off
            [val,id] = max(response);
            area_ppc.suppression_index(cn) = 1 - response(end)/max(response);
            area_ppc.peak_diameter(cn) = area(id);
            
            small_trials = tuning_data.TrialIV<=area_ppc.peak_diameter(cn);
            large_trials = tuning_data.TrialIV>=area_ppc.peak_diameter(cn);
            
            
            
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
            
            small_spikes = spike_iv<=area_ppc.peak_diameter(cn);
            large_spikes = spike_iv>=area_ppc.peak_diameter(cn);
            
            %%
            %calculate ps and ppc
            
            area_ppc.f = f;
            
            %ps for spike triggered LFP
            ps_lfp_all = LFP.custom_fft(lfp,f,fs);
            ps_lfp_small = LFP.custom_fft(lfp(:,small_spikes & spike_opto==0 & ~noise_trials),f,fs);
            ps_lfp_large = LFP.custom_fft(lfp(:,large_spikes & spike_opto==0 & ~noise_trials),f,fs);
            
            area_ppc.ps_lfp_small(cn,:) = nanmean(abs(ps_lfp_small),2).^2;
            area_ppc.ps_lfp_large(cn,:) = nanmean(abs(ps_lfp_large),2).^2;
            
            phase_angles_small = angle(ps_lfp_small);
            area_ppc.ppc_small(cn,:) = LFP.ppc(phase_angles_small);
            
            phase_angles_large = angle(ps_lfp_large);
            area_ppc.ppc_large(cn,:) = LFP.ppc(phase_angles_large);
            
            figure(2),plot(f,area_ppc.ppc_small(cn,:),'r')
            hold on
            figure(2),plot(f,area_ppc.ppc_large(cn,:),'b')
            hold off
            
            figure(3),plot(f,nanmean(area_ppc.ppc_small,1),'r')
            hold on
            figure(3),plot(f,nanmean(area_ppc.ppc_large,1),'b')
            hold off
            
            
            
            
            
            
            ps_spike_small = LFP.custom_fft(spike_psth(small_trials,:)',f,fs_spiking);
            ps_spike_large = LFP.custom_fft(spike_psth(large_trials,:)',f,fs_spiking);
            
            
            
            area_ppc.ps_spike_small(cn,:) = nanmean(abs(ps_spike_small),2).^2;
            area_ppc.ps_spike_large(cn,:) = nanmean(abs(ps_spike_large),2).^2;
            
            %%
            %spectrogram for ppc
            area_ppc.spectrogram_time = ppc_x;
        
            for time_index =1:length(ppc_x)
                
                current_spikes = spike_time_bin>= time_index-1 & spike_time_bin<= time_index+1 & small_spikes;
                phase_angles_small = angle(ps_lfp_all(:,current_spikes));
                area_ppc.ppc_spectrogram_small(cn,:,time_index) = LFP.ppc(phase_angles_small);
                
                
                current_spikes = spike_time_bin>= time_index-1 & spike_time_bin<= time_index+1 & large_spikes;
                phase_angles_large = angle(ps_lfp_all(:,current_spikes));
                area_ppc.ppc_spectrogram_large(cn,:,time_index) = LFP.ppc(phase_angles_large);
                
                
                
                
            end
            toc
            figure(1),imagesc(squeeze( area_ppc.ppc_spectrogram_large(cn,:,:)))
            figure(10),imagesc(squeeze(nanmean(area_ppc.ppc_spectrogram_large)))
            %save(FileName,'area_ppc','-append')
            pause(1)
        end
    end
    
    
end


