function BatchCalculate_boxdonuts_pupil(data_set,varargin)
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
    
    if current_excel_line.Exclude==0 & contains(FileName,file_check)
        
        load(FileName,'data')
        clear leg
        tuning_data = AlertTuning;
        %data.SpikeData.RawSpikeTimes = data.SpikeData.RawSpikeTimes + 23.3700;
        [TrialParameters,CompletedTrials] = AlertTuning.TextKeyExtract(data);
        
        spikes = data.SpikeData.RawSpikeTimes;
        triggers = CompletedTrials.Stimulus;
        params.cycle_bin_number = 16;
        params.pre_window = -.5;
        params.bin_size =  0.02;
        params.max_trial_duration = 1;
        params.TF = str2num(data.Parameters.Stimulus.TemporalFrequency);
        
        [Pupil.onset_y,Pupil.offset_y,Pupil.x] =PupilSize.by_trial(data.Parameters.ParameterChannels.PupilData.Eyd.data,CompletedTrials);
  
        tuning_data = AlertTuning.CalculateTuningCurve_w_pupil(spikes,triggers,Pupil,CompletedTrials.IV,params);
        
        small_pupil_trials = tuning_data.TrialPupil_Z'<= 0;
        large_pupil_trials = tuning_data.TrialPupil_Z'>= 0;
        
        tuning_data.FileName = FileName;
        tuning_data.combo_list =  CompletedTrials.combo_list;
        
        [primary_tuning_small, secondary_tuning_small, primary_unique_small, secondary_unique_small] =Utilities.box_nested_w_pupil(tuning_data,small_pupil_trials);
        primary_tuning_small.FileName = FileName;
        secondary_tuning_small.FileName = FileName;
        figure(1),subplot(1,2,1),cla,hold on, axis square
        subfields = Utilities.box_plot(primary_tuning_small, primary_unique_small,secondary_unique_small);
        xlabel(subfields(1).secondary)
        figure(1),subplot(1,2,1),hold off
        
        figure(2),subplot(1,2,1),cla,hold on, axis square
        subfields = Utilities.box_plot(secondary_tuning_small, secondary_unique_small,primary_unique_small);
        xlabel(subfields(1).primary)
        figure(2),subplot(1,2,1),hold off
        
        
        [primary_tuning_large, secondary_tuning_large, primary_unique_large, secondary_unique_large] =Utilities.box_nested_w_pupil(tuning_data,large_pupil_trials);
        primary_tuning_large.FileName = FileName;
        secondary_tuning_large.FileName = FileName;
        figure(1),subplot(1,2,2),cla,hold on, axis square
        subfields = Utilities.box_plot(primary_tuning_large, primary_unique_large,secondary_unique_large);
        xlabel(subfields(1).secondary)
        figure(1),subplot(1,2,2),hold off
        
        figure(2),subplot(1,2,2),cla,hold on, axis square
        subfields = Utilities.box_plot(secondary_tuning_large, secondary_unique_large,primary_unique_large);
        xlabel(subfields(1).primary)
        figure(2),subplot(1,2,2),hold off
        


        
    figure(3),subplot(1,2,1),plot(tuning_data.TrialPupil_Z,tuning_data.TrialMean_Z,'o'),axis square
    figure(3),subplot(1,2,2),plot(tuning_data.TrialPupil_Z,tuning_data.TrialF1_Z,'+'),axis square
    
    [r,p] =  corrcoef(tuning_data.TrialPupil_Z,tuning_data.TrialMean_Z)
    
    
    [r,p] =  corrcoef(tuning_data.TrialPupil_Z,tuning_data.TrialF1_Z)
    
        
        
    figure(4),plot(tuning_data.Stimulus(:,1),tuning_data.TrialMean_Z,'b')
    hold on
    figure(4),plot(tuning_data.Stimulus(:,1),tuning_data.TrialPupil_Z,'r')
    hold off

    end
    
    
    
end





     