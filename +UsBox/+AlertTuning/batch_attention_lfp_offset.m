function attention_lfp_offset = batch_attention_lfp_offset(data_set,varargin)

f = 1:100;
f2 = 10.^(-.6:.025:1);
alpha_band = f> 9 & f<18;
gamma_band = f> 30 & f<40;
attention_lfp_offset.f = f;
attention_lfp_offset.f2 = f2;
wavenumber = 6;
post_window = 1;
LoopVar = Spike2.StartLoop(data_set,varargin);
tic

cn = 0;
all_data.f = f;
trial_duration_limit=1;

for file_index =LoopVar.start_index:LoopVar.end_index
    display(['Reading excel row ' num2str(LoopVar.true_row_index(file_index))])
    [current_excel_line] = Spike2.BuildExcelDataField(LoopVar.column_names,LoopVar.excel_data(file_index,:));
    %     figure(1),clf
    %     figure(2),clf
    %     figure(3),clf
    if current_excel_line.Exclude == 0 & contains(current_excel_line.FileName,'atn') & current_excel_line.ContinuousChannel>0
        
        FileName = Utilities.ConstructFileName(data_set,current_excel_line);
        load(FileName,'data','continuous_recording');
        
        if str2num(data.Parameters.Stimulus.TemporalFrequency)>.1
            cn=cn+1;
            
            TimeRange = eval(current_excel_line.TimeRange);
            
            stim_band = f==str2num(data.Parameters.Stimulus.TemporalFrequency);
            fs = continuous_recording.Fs;
            attention_data = AttentionData;
            %obj.PSTH_bin_size = 1/data.Parameters.StimParameters.TF;
            attention_data.PSTH_bin_size = .02;
            attention_data = attention_data.Calculate(data);
            attention_data.CueAll(attention_data.CueAll<0)=0;
            
            
            no_attention_trials = attention_data.CueLocation ==6;
            
            
            
            toward_trials = attention_data.CueLocation == attention_data.RFLocation & attention_data.CueAll ==0 & attention_data.Stimulus(:,1)>TimeRange(1)...
                & attention_data.Stimulus(:,1)<TimeRange(2) & ~no_attention_trials;
            away_trials = attention_data.CueLocation ~= attention_data.RFLocation & attention_data.CueAll ==0 & attention_data.CueLocation ...
                & attention_data.Stimulus(:,1)>TimeRange(1) & attention_data.Stimulus(:,1)<TimeRange(2) & ~no_attention_trials;
            
            
            

            %         figure(1),plot(tuning_data.IV,tuning_data.Mean,'+-')
            %         hold off
            %
            %         figure(2),plot(CompletedTrials.Stimulus(:,1),tuning_data.TrialF1)
            %         xlabel('time')
            %         ylabel('F1')
            clear TrialF1_z
      
            
            %         figure(3),plot(CompletedTrials.Stimulus(:,1),TrialF1_z,'o')
            %          xlabel('time')
            %         ylabel('F1 z')
            
            TimeRange = eval(current_excel_line.TimeRange);
            good_trials = attention_data.Stimulus(:,1)>TimeRange(:,1) & attention_data.Stimulus(:,2)<TimeRange(:,2);
            attention_data.Stimulus(~good_trials,:) = nan;
    
            triggers = attention_data.Stimulus;
            
            [lfp,triggers] = LFP.TrialDivision_offset(continuous_recording, triggers, trial_duration_limit, post_window);
            
            [lfp.y, noise_trials]  = AlertTuning.NoiseTrials(lfp.y);
            lfp.y(~isfinite(lfp.y)) = 0;
            lfp.y(:,noise_trials) = nan;
            ft = LFP.custom_fft(lfp.y,f,fs);
            
            %
            %         figure(4),plot(f,abs(ft),'r')
            %         hold on
            %         figure(4),plot(f,nanmean(abs(ft),2),'LineWidth',5)
            %         hold off
            [val,alpha_peak_id] = max(nanmean(abs(ft(alpha_band,:)),2));
            temp_alpha = find(alpha_band);
            alpha_peak_id = temp_alpha(alpha_peak_id);
            [val,gamma_peak_id] = max(nanmean(abs(ft(gamma_band,:)),2));
            temp_gamma = find(gamma_band);
            gamma_peak_id = temp_gamma(gamma_peak_id);
            
            
            alpha_power = max(abs(ft(alpha_band,:)));
            percent_change = band_diff(alpha_power,attention_data.Stimulus(:,1));
            attention_lfp_offset.alpha_change_rate(cn,:) = [percent_change.raw nanmean(percent_change.shuffle)];
            
            alpha_power_z = (alpha_power-nanmean(alpha_power))./std(alpha_power);
            stim_power = (abs(ft(stim_band,:)));
            
            %         figure(5),plot(alpha_power,TrialF1_z,'o')
            %         xlabel('alpha power'),ylabel('Trial F1 z')
            %         figure(6),plot(alpha_power_z,TrialF1_z,'o')
            %         xlabel('alpha power z'),ylabel('Trial F1 z')
            %         figure(7),plot(CompletedTrials.Stimulus(:,1),alpha_power,'o')
            %         hold on
            %         figure(7),plot(CompletedTrials.Stimulus(:,1),smooth(alpha_power,5),'-k')
            %         hold off
            %         xlabel('time'),ylabel('alpha power')
            %         [r,p] = corrcoef(alpha_power,TrialF1_z)
            %         [r,p] = corrcoef(alpha_power,tuning_data.TrialF1)
            %
            %         [r,p] = corrcoef(stim_power,TrialF1_z)
            %
            %         [r,p] = corrcoef(alpha_power,stim_power)
            %         if sum(stim_band)>0
            %             figure(8),plot(stim_power,alpha_power,'+')
            %         end
            
            toc
            noise_limit = std(continuous_recording.Y)*5;
            noise_bins = abs(continuous_recording.Y)>noise_limit;
            
            continuous_recording.Y(noise_bins) = nan;
            
            [B,T,F]=LFP.BOSC.BOSC_tf(continuous_recording.Y,f,continuous_recording.Fs,wavenumber);
            r = randperm(length(continuous_recording.Y));
            scramble = continuous_recording.Y(r);
            [B_scramble,T,F]=LFP.BOSC.BOSC_tf(scramble,f,continuous_recording.Fs,wavenumber);
            bin_size = 1/continuous_recording.Fs;
            spectrogram = calculate_spectrogram(B,continuous_recording.X,triggers, bin_size, trial_duration_limit, post_window);
            
            
            baseline = spectrogram.x<-.1;
            baseline = squeeze(nanmean(nanmean(spectrogram.y(:,:,baseline),3),1));
            baseline = repmat(baseline,size(spectrogram.y,1),1,size(spectrogram.y,3));
            spectrogram.y_norm = spectrogram.y./baseline;
            attention_lfp_offset.spectrogram_time = spectrogram.x;
%             figure(1),imagesc(squeeze(nanmean(spectrogram.y)))
%             x = get(gca,'xtick');
%             set(gca,'xticklabel',spectrogram.x(x))
%             y = get(gca,'ytick');
%             set(gca,'yticklabel',f(y))
%             colorbar
%             figure(2),imagesc(squeeze(nanmean(spectrogram.y_bs)))
%             x = get(gca,'xtick');
%             set(gca,'xticklabel',spectrogram.x(x))
%             y = get(gca,'ytick');
%             set(gca,'yticklabel',f(y))
%             colorbar
%             figure(10),plot(squeeze(nanmean(nanmean(spectrogram.y),3)))
%             figure(11),plot(squeeze(nanmean(nanmean(spectrogram.y_bs),3)))
            
            attention_lfp_offset.spectrogram(cn,:,:) = squeeze(nanmean(spectrogram.y));
            attention_lfp_offset.spectrogram_norm(cn,:,:) = squeeze(nanmean(spectrogram.y_norm));
            
            attention_lfp_offset.spectrogram_away(cn,:,:) = squeeze(nanmean(spectrogram.y(away_trials,:,:)));
            attention_lfp_offset.spectrogram_away_norm(cn,:,:) = squeeze(nanmean(spectrogram.y_norm(away_trials,:,:)));
            
            attention_lfp_offset.spectrogram_toward(cn,:,:) = squeeze(nanmean(spectrogram.y(toward_trials,:,:)));
            attention_lfp_offset.spectrogram_toward_norm(cn,:,:) = squeeze(nanmean(spectrogram.y_norm(toward_trials,:,:)));
            alpha_power = continuous_recording;
            
            alpha_power.Y = B(alpha_peak_id,:);
            
            
            [stim_locked,triggers] = LFP.TrialDivision(alpha_power,triggers,trial_duration_limit, post_window);
            attention_lfp_offset.alpha_stim_time = stim_locked.x;
            attention_lfp_offset.alpha_stim_locked(cn,:) = nanmean(stim_locked.y,2)/nanmean(alpha_power.Y);;
            attention_lfp_offset.alpha_stim_locked_away(cn,:) = nanmean(stim_locked.y(:,away_trials),2)/nanmean(alpha_power.Y);;
            attention_lfp_offset.alpha_stim_locked_toward(cn,:) = nanmean(stim_locked.y(:,toward_trials),2)/nanmean(alpha_power.Y);;
            %              figure(3),plot(stim_locked.x,attention_lfp.alpha_stim_locked(cn,:))
            
            r = randperm(size(B,2));
            %             alpha_power.Y = B(alpha_peak_id,r);
            %             [alpha_stim_scramble,triggers] = LFP.TrialDivision(alpha_power,triggers,trial_duration_limit, pre_window);
            
            random_triggers = sort(rand(1,size(triggers,1))*max(continuous_recording.X))';
            random_triggers(:,2) = random_triggers(:,1)+ trial_duration_limit;
            [stim_locked,triggers] = LFP.TrialDivision(alpha_power,random_triggers,trial_duration_limit, post_window);
            attention_lfp_offset.alpha_stim_random(cn,:) = nanmean(stim_locked.y,2)/nanmean(alpha_power.Y);
%             figure(11),plot(alpha_stim_locked.x,nanmean(alpha_stim_random.y./nanmean(B(alpha_peak_id,:)),2))
%             hold on
%             figure(11),plot(alpha_stim_locked.x,nanmean(alpha_stim_locked.y./nanmean(B(alpha_peak_id,:)),2))
%             hold off
            
            %         figure(1),subplot(4,1,1),plot(continuous_recording.X,B(alpha_peak_id,:))
            %         figure(1),subplot(4,1,2),plot(continuous_recording.X,B_scramble(alpha_peak_id,:))
            %         figure(1),subplot(4,1,3),plot(continuous_recording.X,B(gamma_peak_id,:))
            %         figure(1),subplot(4,1,4),plot(continuous_recording.X,sum(B(:,:)))
            
            %         [alpha_wavlet,T,F]=LFP.BOSC.BOSC_tf(B(alpha_peak_id,:),f2,continuous_recording.Fs,wavenumber);
            %
            %         figure(2),semilogx(f2,nanmean(alpha_wavlet,2))
            attention_lfp_offset.away_auto_corr(cn,:) = xcorr(B(1,:),'normalized',1000);
            attention_lfp_offset.away_scramble_corr(cn,:) = xcorr(B_scramble(1,:),'normalized',1000);
        
            attention_lfp_offset.stim_auto_corr(cn,:) = xcorr(B(stim_band,:),'normalized',1000);
            attention_lfp_offset.stim_scramble_corr(cn,:) = xcorr(B_scramble(stim_band,:),'normalized',1000);
            
            attention_lfp_offset.alpha_auto_corr(cn,:) = xcorr(B(alpha_peak_id,:),'normalized',1000);
            attention_lfp_offset.alpha_scramble_corr(cn,:) = xcorr(B_scramble(alpha_peak_id,:),'normalized',1000);
            attention_lfp_offset.gamma_auto_corr(cn,:) = xcorr(B(gamma_peak_id,:),'normalized',1000);
            attention_lfp_offset.gamma_scramble_corr(cn,:) = xcorr(B_scramble(gamma_peak_id,:),'normalized',1000);
            
            attention_lfp_offset.toward_auto_corr(cn,:) = xcorr(B(end,:),'normalized',1000);
            attention_lfp_offset.toward_scramble_corr(cn,:) = xcorr(B_scramble(end,:),'normalized',1000);
            
            
            attention_lfp_offset.away_ft(cn,:) = LFP.custom_fft(attention_lfp_offset.away_auto_corr(cn,:)',f2,fs);
            attention_lfp_offset.away_scramble_ft(cn,:) = LFP.custom_fft(attention_lfp_offset.away_scramble_corr(cn,:)',f2,fs);
            
            attention_lfp_offset.stim_ft(cn,:) = LFP.custom_fft(attention_lfp_offset.stim_auto_corr(cn,:)',f2,fs);
            attention_lfp_offset.stim_scramble_ft(cn,:) = LFP.custom_fft(attention_lfp_offset.stim_scramble_corr(cn,:)',f2,fs);
            
            attention_lfp_offset.alpha_ft(cn,:) = LFP.custom_fft(attention_lfp_offset.alpha_auto_corr(cn,:)',f2,fs);
            attention_lfp_offset.alpha_scramble_ft(cn,:) = LFP.custom_fft(attention_lfp_offset.alpha_scramble_corr(cn,:)',f2,fs);
            attention_lfp_offset.gamma_ft(cn,:) = LFP.custom_fft(attention_lfp_offset.gamma_auto_corr(cn,:)',f2,fs);
            attention_lfp_offset.gamma_scramble_ft(cn,:) = LFP.custom_fft(attention_lfp_offset.gamma_scramble_corr(cn,:)',f2,fs);
            
            attention_lfp_offset.toward_ft(cn,:) = LFP.custom_fft(attention_lfp_offset.toward_auto_corr(cn,:)',f2,fs);
            attention_lfp_offset.toward_scramble_ft(cn,:) = LFP.custom_fft(attention_lfp_offset.toward_scramble_corr(cn,:)',f2,fs);
            
            %         figure(3),subplot(4,1,1),bar((-1000:1000)/fs,attention_lfp.alpha_auto_corr(cn,:))
            %         hold on
            %         figure(3),subplot(4,1,1),plot((-1000:1000)/fs,attention_lfp.alpha_scramble_corr(cn,:),'linewidth',3)
            %         hold off
            %         figure(3),subplot(4,1,2),bar((-1000:1000)/fs,attention_lfp.alpha_auto_corr(cn,:) - attention_lfp.alpha_scramble_corr(cn,:))
            %         figure(3),subplot(4,1,3),bar((-1000:1000)/fs,gamma_auto_corr)
            %         figure(3),subplot(4,1,4),bar((-1000:1000)/fs,sum_auto_corr)
            %         figure(4),semilogx(f2,abs(attention_lfp.alpha_ft(cn,:))/sum(abs(attention_lfp.alpha_ft(cn,:))))
            %         hold on
            %         figure(4),semilogx(f2,abs(attention_lfp.alpha_scramble_ft(cn,:))/sum(abs(attention_lfp.alpha_scramble_ft(cn,:))))
            % %         figure(4),semilogx(f2,abs(gamma_ft)/sum(abs(gamma_ft)))
            % %         figure(4),semilogx(f2,abs(sum_ft)/sum(abs(sum_ft)))
            %         legend('alpha','scramble')
            %         hold off
            
            
        end
    end
    
end

figure(1),plot(attention_lfp_offset.f2,nanmean(abs(attention_lfp_offset.alpha_ft) - abs(attention_lfp_offset.alpha_scramble_ft))./nanmean(abs(attention_lfp_offset.alpha_ft)))
hold on
figure(1),plot(attention_lfp_offset.f2,nanmean(abs(attention_lfp_offset.gamma_ft) - abs(attention_lfp_offset.gamma_scramble_ft))./nanmean(abs(attention_lfp_offset.gamma_ft)))
% figure(1),plot(attention_lfp.f2,nanmean(abs(attention_lfp.away_ft) - abs(attention_lfp.away_scramble_ft))./nanmean(abs(attention_lfp.away_ft)))
% figure(1),plot(attention_lfp.f2,nanmean(abs(attention_lfp.stim_ft) - abs(attention_lfp.stim_scramble_ft))./nanmean(abs(attention_lfp.stim_ft)))
% figure(1),plot(attention_lfp.f2,nanmean(abs(attention_lfp.toward_ft) - abs(attention_lfp.toward_scramble_ft))./nanmean(abs(attention_lfp.toward_ft)))
hold off
legend('alpha','gamma')
xlabel('frequency')
ylabel('power')
set(gca,'ylim',[-.2 1])

figure(2),plot(attention_lfp_offset.alpha_stim_time,nanmean(attention_lfp_offset.alpha_stim_locked))
hold on
figure(2),plot(attention_lfp_offset.alpha_stim_time,nanmean(attention_lfp_offset.alpha_stim_locked_away))
figure(2),plot(attention_lfp_offset.alpha_stim_time,nanmean(attention_lfp_offset.alpha_stim_locked_toward))
figure(2),plot(attention_lfp_offset.alpha_stim_time,nanmean(attention_lfp_offset.alpha_stim_random))
hold off
legend('all','away','toward','random')
xlabel('time')
ylabel('amp')

figure(4),subplot(1,3,1),imagesc(squeeze(nanmean(attention_lfp_offset.spectrogram_norm))), axis square
figure(4),subplot(1,3,2),imagesc(squeeze(nanmean(attention_lfp_offset.spectrogram_away_norm))), axis square
figure(4),subplot(1,3,3),imagesc(squeeze(nanmean(attention_lfp_offset.spectrogram_toward_norm))), axis square
figure(5),imagesc((squeeze(nanmean(attention_lfp_offset.spectrogram_toward_norm))-...
    squeeze(nanmean(attention_lfp_offset.spectrogram_away_norm)))./(squeeze(nanmean(attention_lfp_offset.spectrogram_toward_norm)))), axis square
colorbar
end


function  percent_change = band_diff(power,time)

percent_change.raw = nanmean(abs(diff(power)))/nanmean(power);

for index = 1:1000
    r = randperm(length(power));
   percent_change.shuffle(index)   = nanmean(abs(diff(power(r))))/nanmean(power);
    
    
    
end






end

function spectrogram = calculate_spectrogram(ps,time,triggers, bin_size, trial_duration_limit, pre_window)



spectrogram.x = -1*pre_window:bin_size:trial_duration_limit;
spectrogram.y = nan(size(triggers,1),size(ps,1),length(spectrogram.x));

for trial_index = 1:size(triggers,1)
    
    current_triggers  = triggers(trial_index,:);
    trial_duration = current_triggers(2) - current_triggers(1);
    
    if trial_duration> trial_duration_limit
        
        current_triggers(2) = current_triggers(1) + trial_duration_limit;
   
    end
    
    current_bins = time>current_triggers(1)-pre_window & time<current_triggers(2);
    
    spectrogram.y(trial_index,:,1:sum(current_bins)) = ps(:,current_bins);
    
    
end

end