function BatchCalculate_w_pupil(data_set,varargin)
%calculate tuning curve data. Sesigned to be called after Spike2.BatchLoad
%
%inputs : data_set = a DataSet class object
%
%(optional)
%start_index = start row of the excel spreadsheet (default = data_set.ExcelRange(1));
%end_index = end row of the excel spreadsheet
%optional:
% file_type: A string that is a substrin of tje file names you want to work with. 
% example file_type = 'con' will grab a1_con_001.mat, but ignore a1_spa_001.mat
%default: any (will grab all files)

LoopVar = Spike2.StartLoop(data_set,varargin);

for file_index =LoopVar.start_index:LoopVar.end_index
    [current_excel_line] = Spike2.BuildExcelDataField(LoopVar.column_names,LoopVar.excel_data(file_index,:));
    
    FileName    = Spike2.ConstructFileName(data_set,current_excel_line);
    
    display(['Reading excel row ' num2str(LoopVar.true_row_index(file_index))])
    
    
    if strcmp(LoopVar.file_type,'any')
        file_check = FileName;
    else
        file_check = LoopVar.file_type;
    end
    time_range =  eval(current_excel_line.TimeRange);
    if current_excel_line.Exclude==0 & contains(FileName,file_check)
  
        load(FileName,'data','pupil_data')
     
        [TrialParameters,CompletedTrials] = AlertTuning.TextKeyExtract(data);
        %CompletedTrials.Stimulus(:,2) = CompletedTrials.Stimulus(:,1)+.250 ;
        spikes = data.SpikeData.RawSpikeTimes;
     
        params.cycle_bin_number = 16;
        params.pre_window = -.5;
        params.bin_size =  0.02;
        params.max_trial_duration = 1;
        params.TF = str2num(data.Parameters.Stimulus.TemporalFrequency);
        
        
        pupil_data = PupilSize.remove_blinks(pupil_data);
        
        
        
        %sort pupil data into trials
        
        [Pupil.onset_y,Pupil.offset_y,Pupil.x] =PupilSize.by_trial(pupil_data,CompletedTrials.Stimulus);
        pupil_trial_average = nanmean(Pupil.onset_y,2);
    
        
        %z-score pupil size
        pupil_trial_z=(pupil_trial_average-nanmean(pupil_trial_average))/nanstd(pupil_trial_average);
        
        
        %currently the definition of "small" and "large" only depends on
        %the distribution of pupil sizes within the current trial.
        small_pupil = pupil_trial_z<-1  & CompletedTrials.Stimulus(:,1)>time_range(1) & ...
                CompletedTrials.Stimulus(:,2)<time_range(2);
        large_pupil = pupil_trial_z>1  & CompletedTrials.Stimulus(:,1)>time_range(1) & ...
                CompletedTrials.Stimulus(:,2)<time_range(2);
        
        
        
        
        
        
        
        tuning_data_small_pupil = AlertTuning.CalculateTuningCurve(spikes,CompletedTrials.Stimulus(small_pupil,:),CompletedTrials.IV(small_pupil,:),params);
        tuning_data_large_pupil = AlertTuning.CalculateTuningCurve(spikes,CompletedTrials.Stimulus(large_pupil,:),CompletedTrials.IV(large_pupil,:),params);


%         
%         tuning_data.combo_list =CompletedTrials.combo_list;
%         
%         tuning_data.Stimulus = CompletedTrials.Stimulus;
    
        
        small_e = nanstd(tuning_data_small_pupil.TrialPSTH)/sqrt(size(tuning_data_small_pupil.TrialPSTH,1));
        large_e = nanstd(tuning_data_large_pupil.TrialPSTH)/sqrt(size(tuning_data_large_pupil.TrialPSTH,1));
        figure(1),subplot(1,3,1),plot(tuning_data_small_pupil.PSTH_X(1:end-1),nanmean(tuning_data_small_pupil.TrialPSTH),'b')
        hold on
        plot(tuning_data_large_pupil.PSTH_X(1:end-1),nanmean(tuning_data_large_pupil.TrialPSTH),'r')
        Utilities.CreateErrorPatch(tuning_data_small_pupil.PSTH_X(1:end-1),nanmean(tuning_data_small_pupil.TrialPSTH),small_e,'b');
        Utilities.CreateErrorPatch(tuning_data_large_pupil.PSTH_X(1:end-1),nanmean(tuning_data_large_pupil.TrialPSTH),large_e,'r');
        hold off
        xlabel('time')
        ylabel('response')
        axis square
        diff = (nanmean(tuning_data_large_pupil.TrialPSTH) - nanmean(tuning_data_small_pupil.TrialPSTH));
        figure(1),subplot(1,3,2),plot(tuning_data_large_pupil.PSTH_X(1:end-1),diff)
        xlabel('time')
        ylabel('respponse diff (large-small)')
        axis square
        figure(1),subplot(1,3,3),plot(tuning_data_large_pupil.PSTH_X(1:end-1),cumsum(diff)/nansum(nanmean(tuning_data_large_pupil.TrialPSTH)))
        axis square
        xlabel('time')
        ylabel('cum respponse diff (large-small)')
        hold off
        figure(2),clf
        if isfinite(max(tuning_data_small_pupil.F1))
            figure(2),subplot(1,2,1),plot(tuning_data_small_pupil.IV,tuning_data_small_pupil.F1,'+-b')
            hold on
            plot(tuning_data_large_pupil.IV,tuning_data_large_pupil.F1,'+-r')
            Utilities.CreateErrorPatch(tuning_data_small_pupil.IV,tuning_data_small_pupil.F1,tuning_data_small_pupil.F1_e,'b');
            Utilities.CreateErrorPatch(tuning_data_large_pupil.IV,tuning_data_large_pupil.F1,tuning_data_large_pupil.F1_e,'r');
            hold off
            axis square
            title('F1')
        end
        figure(2),subplot(1,2,2),plot(tuning_data_small_pupil.IV,tuning_data_small_pupil.Mean,'+-b')
        hold on
        plot(tuning_data_large_pupil.IV,tuning_data_large_pupil.Mean,'+-r')
        Utilities.CreateErrorPatch(tuning_data_small_pupil.IV,tuning_data_small_pupil.Mean,tuning_data_small_pupil.Mean_e,'b');
        Utilities.CreateErrorPatch(tuning_data_large_pupil.IV,tuning_data_large_pupil.Mean,tuning_data_large_pupil.Mean_e,'r');
        hold off
        axis square
        xlabel('IV')
        ylabel('response')
        title('mean')
        fprintf('small pupil count  = %i\n', sum(small_pupil))
        fprintf('large pupil count  = %i\n', sum(large_pupil))
       
        pause
        
    end
    
    
    
end





     