function BatchCalculate_boxdonuts(data_set,varargin)
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
        
        [TrialParameters,CompletedTrials] = AlertTuning.TextKeyExtract(data);
        
        spikes = data.SpikeData.RawSpikeTimes;
        triggers = CompletedTrials.Stimulus;
        params.cycle_bin_number = 16;
        params.pre_window = -.5;
        params.bin_size =  0.02;
        params.max_trial_duration = 1;
        params.TF = str2num(data.Parameters.Stimulus.TemporalFrequency);
 
        
        tuning_data = AlertTuning.CalculateTuningCurve(spikes,triggers,CompletedTrials.IV,params);
        
        primary_unique = unique(CompletedTrials.combo_list(:,1));
        secondary_unique = unique(CompletedTrials.combo_list(:,2));
        clear primary_color
        clear secondary_color
        figure(1),clf
        figure(1),subplot(1,3,1),cla,set(gca, 'ColorOrder', hsv(length(primary_unique))), axis square, hold on
        figure(1),subplot(1,3,2),cla,set(gca, 'ColorOrder', hsv(length(primary_unique))), axis square, hold on
        figure(1),subplot(1,3,3),cla,set(gca, 'ColorOrder', hsv(length(primary_unique))), axis square, hold on
        
%         figure(4),clf,hold on
%         
        figure(2),clf
        figure(2),subplot(1,3,1),cla,set(gca, 'ColorOrder', hsv(length(primary_unique))), axis square, hold on
        figure(2),subplot(1,3,2),cla,set(gca, 'ColorOrder', hsv(length(primary_unique))), axis square, hold on
        figure(2),subplot(1,3,3),cla,set(gca, 'ColorOrder', hsv(length(primary_unique))), axis square, hold on
        
        figure(22),clf
        figure(22),subplot(1,2,1),cla,set(gca, 'ColorOrder', hsv(length(primary_unique))), axis square, hold on
        figure(22),subplot(1,2,2),cla,set(gca, 'ColorOrder', hsv(length(primary_unique))), axis square, hold on
        primary_tuning.IV = primary_unique;
        secondary_tuning.IV = secondary_unique;
        L = 0;
        for iv_index =1:length(primary_unique)
      
           current_combo =  find(CompletedTrials.combo_list(:,1)==primary_unique(iv_index));
           current_trials = ismember(tuning_data.TrialIV,current_combo);
           current_id = tuning_data.TrialIV(current_trials);
           unique_current_id = unique(current_id);
           
           for secondary_index = 1:length(unique_current_id);
               current_trials = tuning_data.TrialIV==unique_current_id(secondary_index);
               primary_tuning.F1(iv_index,secondary_index) = nanmean(tuning_data.TrialF1(current_trials));
               primary_tuning.F1_e(iv_index,secondary_index) = nanstd(tuning_data.TrialF1(current_trials))/sqrt(sum(current_trials));
               
               primary_tuning.F2(iv_index,secondary_index) = nanmean(tuning_data.TrialF2(current_trials));
               primary_tuning.F2_e(iv_index,secondary_index) = nanstd(tuning_data.TrialF2(current_trials))/sqrt(sum(current_trials));
               
               primary_tuning.Mean(iv_index,secondary_index) = nanmean(tuning_data.TrialMean(current_trials));
               primary_tuning.Mean_e(iv_index,secondary_index) = nanstd(tuning_data.TrialMean(current_trials))/sqrt(sum(current_trials));
               primary_tuning.CycleHist(iv_index,secondary_index,:) = nanmean(tuning_data.TrialCycleHist(current_trials,:));
               primary_tuning.PSTH(iv_index,secondary_index,:) = nanmean(tuning_data.TrialPSTH(current_trials,:));
               primary_tuning.PSTH_e(iv_index,secondary_index,:) = nanstd(tuning_data.TrialPSTH(current_trials,:))/sqrt(sum(current_trials));
            
           end
           
           leg{iv_index} = num2str(primary_unique(iv_index));
           figure(1),subplot(1,3,1),h = plot(secondary_unique,primary_tuning.F1(iv_index,:),'-+');
           text(secondary_unique(end),primary_tuning.F1(iv_index,end),num2str(primary_unique(iv_index)))
           figure(1),subplot(1,3,2),h = plot(secondary_unique,primary_tuning.Mean(iv_index,:),'-o');
           text(secondary_unique(end),primary_tuning.Mean(iv_index,end),num2str(primary_unique(iv_index)))
           figure(1),subplot(1,3,3),h = plot(secondary_unique,primary_tuning.F2(iv_index,:),'-o');
           text(secondary_unique(end),primary_tuning.F2(iv_index,end),num2str(primary_unique(iv_index)))
           primary_color{iv_index} = get(h,'color');
           
           
%            if iv_index>5
%                L=L+1;
%                temp = primary_tuning.F1(iv_index,:)-min(primary_tuning.F1(iv_index,:))
%                figure(4),h = plot(secondary_unique,temp/max(temp),'-+');
%                
%                leg2{L} = num2str(primary_unique(iv_index));
%    
%       
%            end
           
           FigFileName = FileName;
         
     
           
            
            
        end
        [names,extents]  = regexp(FileName,'\\(?<file_name>\w*)\.mat','names','tokenextents');
        FigFileName = ['D:\AwakeData\TuningCurves\' names(1).file_name];
        
        subfields  = regexp(names(1).file_name,'[a-z]*_\d*_[a-z]*_(?<primary>[a-z]{3,7})_(?<secondary>[a-z]{3,7})','names');
        
        
        names(1).file_name = regexprep(names(1).file_name,'_',' ');
        
        
        
       % title(names(1).file_name)
        
        
       for iv_index =1:length(primary_unique)
           if params.TF>0
               figure(1),subplot(1,3,1)
               Utilities.CreateErrorPatch(secondary_unique,primary_tuning.F1(iv_index,:),primary_tuning.F1_e(iv_index,:),primary_color{iv_index});
               
               figure(1),subplot(1,3,3)
               Utilities.CreateErrorPatch(secondary_unique,primary_tuning.F2(iv_index,:),primary_tuning.F2_e(iv_index,:),primary_color{iv_index});
           end
           figure(1),subplot(1,3,2)
           Utilities.CreateErrorPatch(secondary_unique,primary_tuning.Mean(iv_index,:),primary_tuning.Mean_e(iv_index,:),primary_color{iv_index});
     
       end
   
        
        figure(1),subplot(1,3,1),h = legend(leg,'Location','northoutside');
        if ~isempty(subfields)
            xlabel(subfields(1).secondary)
        end
        ylabel('Response(spikes/s)')
        title('F1')
        figure(1),subplot(1,3,2),legend(leg,'Location','northoutside')
        if ~isempty(subfields)
            xlabel(subfields(1).secondary)
        end
        ylabel('Response(spikes/s)')
        title('Mean')
        figure(1),subplot(1,3,3),legend(leg,'Location','northoutside')
        if ~isempty(subfields)
            xlabel(subfields(1).secondary)
        end
        ylabel('Response(spikes/s)')
        title('F2')
        saveas(gcf,[FigFileName '_primary.fig']);

        clear leg

        opto_trials = CompletedTrials.OptoState(:,2)==1;
        nonopto_trials = CompletedTrials.OptoState(:,2)==0;
        
        for iv_index =1:length(secondary_unique)
            
            current_combo =  find(CompletedTrials.combo_list(:,2)==secondary_unique(iv_index));
            current_trials = ismember(tuning_data.TrialIV,current_combo);
            current_id = tuning_data.TrialIV(current_trials);
            unique_current_id = unique(current_id);
            for primary_index = 1:length(unique_current_id);
                
                current_trials = tuning_data.TrialIV==unique_current_id(primary_index);
                secondary_tuning.F1(iv_index,primary_index) = nanmean(tuning_data.TrialF1(current_trials));
                secondary_tuning.F1_e(iv_index,primary_index) = nanstd(tuning_data.TrialF1(current_trials))/sqrt(sum(current_trials));
                
                secondary_tuning.F2(iv_index,primary_index) = nanmean(tuning_data.TrialF2(current_trials));
                secondary_tuning.F2_e(iv_index,primary_index) = nanstd(tuning_data.TrialF2(current_trials))/sqrt(sum(current_trials));
                
                secondary_tuning.Mean(iv_index,primary_index) = nanmean(tuning_data.TrialMean(current_trials));
                secondary_tuning.Mean_e(iv_index,primary_index) = nanstd(tuning_data.TrialMean(current_trials))/sqrt(sum(current_trials));
                
                secondary_tuning.F1_opto(iv_index,primary_index) = nanmean(tuning_data.TrialF1(current_trials & opto_trials));
                secondary_tuning.F1_opto_e(iv_index,primary_index) = nanstd(tuning_data.TrialF1(current_trials & opto_trials))/sqrt(sum(current_trials & opto_trials));
                
                secondary_tuning.Mean_opto(iv_index,primary_index) = nanmean(tuning_data.TrialMean(current_trials & opto_trials));
                secondary_tuning.Mean_opto_e(iv_index,primary_index) = nanstd(tuning_data.TrialMean(current_trials & opto_trials))/sqrt(sum(current_trials & opto_trials));
                
                secondary_tuning.F1_nonopto(iv_index,primary_index) = nanmean(tuning_data.TrialF1(current_trials & nonopto_trials));
                secondary_tuning.F1_nonopto_e(iv_index,primary_index) = nanstd(tuning_data.TrialF1(current_trials & nonopto_trials))/sqrt(sum(current_trials & nonopto_trials));
                
                secondary_tuning.Mean_nonopto(iv_index,primary_index) = nanmean(tuning_data.TrialMean(current_trials & nonopto_trials));
                secondary_tuning.Mean_nonopto_e(iv_index,primary_index) = nanstd(tuning_data.TrialMean(current_trials & nonopto_trials))/sqrt(sum(current_trials & nonopto_trials));
                
                
            end
            leg{iv_index} = num2str(secondary_unique(iv_index));
            figure(22),subplot(1,2,1),hold on
            figure(22),subplot(1,2,2),hold on
            figure(22),subplot(1,2,1),h = plot(primary_unique,secondary_tuning.F1_opto(iv_index,:),'-r+');
            figure(22),subplot(1,2,1),h = plot(primary_unique,secondary_tuning.F1_nonopto(iv_index,:),'-bo');
            text(primary_unique(end),secondary_tuning.F1(iv_index,end),num2str(secondary_unique(iv_index)))
            figure(22),subplot(1,2,2),h = plot(primary_unique,secondary_tuning.Mean_opto(iv_index,:),'-r+');
            figure(22),subplot(1,2,2),h = plot(primary_unique,secondary_tuning.Mean_nonopto(iv_index,:),'-bo');
            text(primary_unique(end),secondary_tuning.Mean(iv_index,end),num2str(secondary_unique(iv_index)))

            
            figure(2),subplot(1,3,1),h = plot(primary_unique,secondary_tuning.F1(iv_index,:),'-+');
            text(primary_unique(end),secondary_tuning.F1(iv_index,end),num2str(secondary_unique(iv_index)))
            figure(2),subplot(1,3,2),h = plot(primary_unique,secondary_tuning.Mean(iv_index,:),'-o');
            text(primary_unique(end),secondary_tuning.Mean(iv_index,end),num2str(secondary_unique(iv_index)))
            figure(2),subplot(1,3,3),h = plot(primary_unique,secondary_tuning.F2(iv_index,:),'-o');
            text(primary_unique(end),secondary_tuning.F2(iv_index,end),num2str(secondary_unique(iv_index)))
            secondary_color{iv_index} = get(h,'color');
            
            
        end
        
        for iv_index =1:length(secondary_unique)
            if params.TF>0
                figure(2),subplot(1,3,1)
                Utilities.CreateErrorPatch(primary_unique,secondary_tuning.F1(iv_index,:),secondary_tuning.F1_e(iv_index,:),secondary_color{iv_index});
                
                figure(2),subplot(1,3,3)
                Utilities.CreateErrorPatch(primary_unique,secondary_tuning.F2(iv_index,:),secondary_tuning.F2_e(iv_index,:),secondary_color{iv_index});
            end
            figure(2),subplot(1,3,2)
            Utilities.CreateErrorPatch(primary_unique,secondary_tuning.Mean(iv_index,:),secondary_tuning.Mean_e(iv_index,:),secondary_color{iv_index});
            
        end
        
       
        figure(2),subplot(1,3,1),legend(leg,'Location','northoutside')
        if ~isempty(subfields)
            xlabel(subfields(1).primary)
        end
        ylabel('F1(spikes/s)')
        figure(2),subplot(1,3,2),legend(leg,'Location','northoutside')
        %title(names(1).file_name)
        if ~isempty(subfields)
            xlabel(subfields(1).primary)
        end
        ylabel('Mean(spikes/s)')
        figure(2),subplot(1,3,3),legend(leg,'Location','northoutside')
        %title(names(1).file_name)
        if ~isempty(subfields)
            xlabel(subfields(1).primary)
        end
        
        ylabel('F2(spikes/s)')
        saveas(gcf,[FigFileName '_secondary.fig']);
        
        figure(3),subplot(1,3,1),plot(tuning_data.PSTH_X(1:end-1), nanmean(tuning_data.PSTH)), axis square
        if ~isempty(subfields)
            xlabel('Time(s)')
        end
        ylabel('Response(spikes/s)')
        title(names(1).file_name)
        figure(3),subplot(1,3,2),plot(tuning_data.PSTH_X(1:end-1), tuning_data.PSTH), axis square
        xlabel('Time(s)')
        ylabel('Response(spikes/s)')
        saveas(gcf,[FigFileName '_PSTH.fig']);
        if ~isempty(subfields)
            primary_tuning.Type = subfields(1).secondary;
            secondary_tuning.Type = subfields(1).primary;
        end
        tic
       % save(FileName,'tuning_data','primary_tuning','secondary_tuning','-append')
        toc
        clear primary_tuning
        clear secondary_tuning
        pause
    end
    
    
    
end





     