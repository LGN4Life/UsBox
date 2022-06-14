function BatchCalculate(data_set,varargin)
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
%opto: true = calculate opt responses (default = false)

LoopVar = Spike2.StartLoop(data_set,varargin);
gauss_x =-5:5;
gauss_filter = 1;%normpdf(gauss_x,0, 1);
figure(1),clf
figure(2),clf
for file_index =LoopVar.start_index:LoopVar.end_index
    [current_excel_line] = Spike2.BuildExcelDataField(LoopVar.column_names,LoopVar.excel_data(file_index,:));
    
    FileName    = Spike2.ConstructFileName(data_set,current_excel_line);
    
    display(['Reading excel row ' num2str(LoopVar.true_row_index(file_index))])
    
    time_range =  eval(current_excel_line.TimeRange);
    if strcmp(LoopVar.file_type,'any')
        file_check = FileName;
    else
        file_check = LoopVar.file_type;
    end
    
    if current_excel_line.Exclude==0 & contains(FileName,file_check)
        
        load(FileName,'data')
        
        
        [TrialParameters,CompletedTrials] = AlertTuning.TextKeyExtract(data);
        %CompletedTrials.Stimulus(:,2) = CompletedTrials.Stimulus(:,1)+.250 ;
        spikes = data.SpikeData.RawSpikeTimes;
        triggers = CompletedTrials.Stimulus;
        params.cycle_bin_number = 16;
        params.pre_window = -.5;
        params.bin_size =  0.02;
        params.max_trial_duration = .5;
        params.TF = str2num(data.Parameters.Stimulus.TemporalFrequency);
        
        
        if LoopVar.opto
           
            opto_trials = CompletedTrials.OptoState(:,2) == 1 & CompletedTrials.Stimulus(:,1)>time_range(1) & ...
                CompletedTrials.Stimulus(:,2)<time_range(2);
            nonopto_trials = CompletedTrials.OptoState(:,2) == 0 & CompletedTrials.Stimulus(:,1)>time_range(1) & ...
                CompletedTrials.Stimulus(:,2)<time_range(2);
            
            if ~isnumeric(current_excel_line.GroupIV)
               new_iv = eval(current_excel_line.GroupIV);
               CompletedTrials.IV = Utilities.GroupIV(CompletedTrials.IV,new_iv); 
                
            end
            
            
            tuning_data.opto = AlertTuning.CalculateTuningCurve(spikes,triggers(opto_trials,:),CompletedTrials.IV(opto_trials),params);
            tuning_data.nonopto = AlertTuning.CalculateTuningCurve(spikes,triggers(nonopto_trials,:),CompletedTrials.IV(nonopto_trials),params);
            %plot_data(tuning_data.opto)
            
            
            psth_e = nanstd(tuning_data.opto.TrialPSTH)/sqrt(size(tuning_data.opto.TrialPSTH,1));
            figure(1),plot(tuning_data.opto.PSTH_X(1:end-1),nanmean(tuning_data.opto.TrialPSTH),'r')
            hold on
            Utilities.CreateErrorPatch(tuning_data.opto.PSTH_X(1:end-1),nanmean(tuning_data.opto.TrialPSTH),psth_e,'r');
            
            
            psth_e = nanstd(tuning_data.nonopto.TrialPSTH)/sqrt(size(tuning_data.nonopto.TrialPSTH,1));
            figure(1),plot(tuning_data.nonopto.PSTH_X(1:end-1),nanmean(tuning_data.nonopto.TrialPSTH),'b')
            hold on
            Utilities.CreateErrorPatch(tuning_data.nonopto.PSTH_X(1:end-1),nanmean(tuning_data.nonopto.TrialPSTH),psth_e,'b');
            hold off
            xlabel('time (s)')
            ylabel('response (spikes/sec)')
            figure(2),subplot(1,2,1),plot(tuning_data.nonopto.IV,tuning_data.nonopto.Mean,'-bo')
            hold on
            figure(2),subplot(1,2,1),plot(tuning_data.nonopto.IV,tuning_data.nonopto.Mean,'-bo')
            Utilities.CreateErrorPatch(tuning_data.nonopto.IV,tuning_data.nonopto.Mean,tuning_data.nonopto.Mean_e,'b');
            figure(2),subplot(1,2,1),plot(tuning_data.opto.IV,tuning_data.opto.Mean,'-ro')
            hold on
            figure(2),subplot(1,2,1),plot(tuning_data.opto.IV,tuning_data.opto.Mean,'-ro')
            Utilities.CreateErrorPatch(tuning_data.opto.IV,tuning_data.opto.Mean,tuning_data.opto.Mean_e,'r');
            hold off
            axis square
            title('Mean')
            xlabel('IV')
            ylabel('response (spikes/sec')
            if str2num(data.Parameters.Stimulus.TemporalFrequency)>0
                figure(2),subplot(1,2,2),plot(tuning_data.nonopto.IV,tuning_data.nonopto.F1,'-bo')
                hold on
                figure(2),subplot(1,2,2),plot(tuning_data.nonopto.IV,tuning_data.nonopto.F1,'-bo')
                Utilities.CreateErrorPatch(tuning_data.nonopto.IV,tuning_data.nonopto.F1,tuning_data.nonopto.F1_e,'b');
                figure(2),subplot(1,2,2),plot(tuning_data.opto.IV,tuning_data.opto.F1,'-ro')
                hold on
                figure(2),subplot(1,2,2),plot(tuning_data.opto.IV,tuning_data.opto.F1,'-ro')
                Utilities.CreateErrorPatch(tuning_data.opto.IV,tuning_data.opto.F1,tuning_data.opto.F1_e,'r');
                hold off
                axis square
                title('F1')
                xlabel('IV')
                ylabel('response (spikes/sec')
            else
                figure(2),subplot(1,2,2),cla
            end
            
            m= max([max(tuning_data.nonopto.PSTH(:)) max(tuning_data.opto.PSTH(:))]);
            for iv_index = 1:length(tuning_data.opto.IV)
                figure(3),subplot(1,length(tuning_data.opto.IV), iv_index)
                plot(tuning_data.nonopto.PSTH(iv_index,:),'b')
                hold on
                plot(tuning_data.opto.PSTH(iv_index,:),'r')
                hold off
                set(gca,'ylim',[0 m])
                axis square
            end
            
     
            
        else
            tuning_data = AlertTuning.CalculateTuningCurve(spikes,triggers,CompletedTrials.IV,params);
            
            tuning_data.combo_list =CompletedTrials.combo_list;
            
            plot_data(tuning_data)
            
            
            
            
        end
        
        %        tuning_data = AlertTuning.plot_xypos(tuning_data,true(length(tuning_data.TrialIV),1))
        if LoopVar.opto
            s_opto = opto_trials;
            s_opto = CompletedTrials.Stimulus(s_opto,1);
            s_nonopto = nonopto_trials;
            s_nonopto = CompletedTrials.Stimulus(s_nonopto,1);
            figure(10),bar(s_opto,tuning_data.opto.TrialMean,'r')
            hold on
            figure(10),bar(s_nonopto,tuning_data.nonopto.TrialMean,'b')
            hold off
        else


            figure(10),bar(CompletedTrials.Stimulus,tuning_data.TrialMean,'b')

        end
        
        pause
    end
    
    
    
end
end

function plot_data(tuning_data)
psth_e = nanstd(tuning_data.TrialPSTH)/sqrt(size(tuning_data.TrialPSTH,1));
            figure(1),subplot(2,1,1),plot(tuning_data.PSTH_X(1:end-1),nanmean(tuning_data.TrialPSTH))
            hold on
            Utilities.CreateErrorPatch(tuning_data.PSTH_X(1:end-1),nanmean(tuning_data.TrialPSTH),psth_e,'b');
            hold off
            figure(1),subplot(2,1,2),plot(tuning_data.PSTH_X(1:end-1),tuning_data.PSTH)
            figure(2),plot(tuning_data.IV,tuning_data.F1,'+-r')
            hold on
            figure(2),plot(tuning_data.IV,tuning_data.F2,'+-g')
            figure(2),plot(tuning_data.IV,tuning_data.Mean,'o-b')
            if sum(isfinite(tuning_data.F1))>0
                Utilities.CreateErrorPatch(tuning_data.IV,tuning_data.F1,tuning_data.F1_e,'r');
                
                Utilities.CreateErrorPatch(tuning_data.IV,tuning_data.F2,tuning_data.F2_e,'g');
            end
            
            
            Utilities.CreateErrorPatch(tuning_data.IV,tuning_data.Mean,tuning_data.Mean_e,'b');
            hold off
            legend('F1','F2','Mean')
            
end





     