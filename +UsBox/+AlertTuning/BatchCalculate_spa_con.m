function BatchCalculate_spa_con(data_set,varargin)
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
cn=0;
for file_index =LoopVar.start_index:LoopVar.end_index
    [current_excel_line] = Spike2.BuildExcelDataField(LoopVar.column_names,LoopVar.excel_data(file_index,:));
    
    FileName    = Spike2.ConstructFileName(data_set,current_excel_line);
    
    display(['Reading excel row ' num2str(LoopVar.true_row_index(file_index))])
    
    

    
    if current_excel_line.Exclude==0 & (contains(FileName,'spa_con') || contains(FileName,'con_spa'))
        cn=cn+1;
        load(FileName,'data')
        clear leg
        tuning_data = AlertTuning;
        %data.SpikeData.RawSpikeTimes = data.SpikeData.RawSpikeTimes + 23.3700;
        tuning_data = tuning_data.Calculate(data);
        
        primary_unique = unique(tuning_data.combo_list(:,1));
        trial_primary_iv = tuning_data.combo_list(tuning_data.TrialIV,1);
        secondary_unique = unique(tuning_data.combo_list(:,2));
        trial_secondary_iv = tuning_data.combo_list(tuning_data.TrialIV,2);
        clear primary_color
        clear secondary_color
        
        figure(1),clf,set(gca, 'ColorOrder', hsv(length(primary_unique)));
        hold all
        primary_tuning.IV2 = primary_unique;
        primary_tuning.IV = secondary_unique;
        
        secondary_tuning.IV2 = secondary_unique;
        secondary_tuning.IV = primary_unique;
        
        for iv_index =1:length(primary_unique)
      
           current_combo =  find(tuning_data.combo_list(:,1)==primary_unique(iv_index));
           current_trials = ismember(tuning_data.TrialIV,current_combo);
           current_id = tuning_data.TrialIV(current_trials);
           unique_current_id = unique(current_id);
           
           for secondary_index = 1:length(secondary_unique);
               current_trials =  trial_primary_iv ==  primary_unique(iv_index) & trial_secondary_iv ==  secondary_unique(secondary_index) ;
               %current_trials = tuning_data.TrialIV==unique_current_id(secondary_index);
               primary_tuning.Mean(iv_index,secondary_index) = nanmean(tuning_data.TrialMean(current_trials));
               primary_tuning.F1(iv_index,secondary_index) = nanmean(tuning_data.TrialF1(current_trials));
               primary_tuning.F1_e(iv_index,secondary_index) = nanstd(tuning_data.TrialF1(current_trials))/sqrt(sum(current_trials));
               
           end
           leg{iv_index} = num2str(primary_unique(iv_index));
 
           figure(1),h = plot(secondary_unique,primary_tuning.F1(iv_index,:),'-+');
           text(secondary_unique(end),primary_tuning.F1(iv_index,end),num2str(primary_unique(iv_index)))
           primary_color{iv_index} = get(h,'color');
           hold on
           
           FigFileName = FileName;
         
     
           
            
            
        end
        [names,extents]  = regexp(FileName,'\\(?<file_name>\w*)\.mat','names','tokenextents');
        FigFileName = ['D:\AwakeData\TuningCurves\' names(1).file_name];
        
        subfields  = regexp(names(1).file_name,'[a-z]*_\d*_[a-z]*_(?<primary>[a-z]{3})_(?<secondary>[a-z]{3})','names');
        
        
        names(1).file_name = regexprep(names(1).file_name,'_',' ');
        
        
        xlabel(subfields(1).secondary)
        ylabel('Response(spikes/s)')
        title(names(1).file_name)
        
        
        for iv_index =1:length(primary_unique)
            Utilities.CreateErrorPatch(secondary_unique,primary_tuning.F1(iv_index,:),primary_tuning.F1_e(iv_index,:),primary_color{iv_index});
            
        end
        figure(1),legend(leg,'Location','bestoutside')
       
        saveas(gcf,[FigFileName '_primary.fig']);
    
        
        clear leg
        
        figure(2),clf,set(gca, 'ColorOrder', hsv(length(secondary_unique)));
        hold all
%         
%         figure(20),clf,set(gca, 'ColorOrder', hsv(length(secondary_unique)));
%         hold all
        
        for iv_index =1:length(secondary_unique)
            
            current_combo =  find(tuning_data.combo_list(:,2)==secondary_unique(iv_index));
            current_trials = ismember(tuning_data.TrialIV,current_combo);
            current_id = tuning_data.TrialIV(current_trials);
            unique_current_id = unique(current_id);
            for primary_index = 1:length(unique_current_id);
                current_trials =  trial_primary_iv ==  primary_unique(primary_index) & trial_secondary_iv ==  secondary_unique(iv_index) ;
                secondary_tuning.Mean(iv_index,primary_index) = nanmean(tuning_data.TrialMean(current_trials));
                secondary_tuning.F1(iv_index,primary_index) = nanmean(tuning_data.TrialF1(current_trials));
                secondary_tuning.F1_e(iv_index,primary_index) = nanstd(tuning_data.TrialF1(current_trials))/sqrt(sum(current_trials));
           
            end
            leg{iv_index} = num2str(secondary_unique(iv_index));
            figure(2),h = plot(primary_unique,secondary_tuning.F1(iv_index,:),'-+');
%             figure(20),subplot(4,4,iv_index),h = plot(primary_unique,secondary_tuning.Mean(iv_index,:),'-+'); hold on
%             figure(20),subplot(4,4,iv_index),h = plot(primary_unique,secondary_tuning.F1(iv_index,:),'-o');
%             
            text(primary_unique(end),secondary_tuning.F1(iv_index,end),num2str(secondary_unique(iv_index)))
            secondary_color{iv_index} = get(h,'color');
            
            
        end
        
         for iv_index =1:length(secondary_unique)
             figure(2)
            Utilities.CreateErrorPatch(primary_unique,secondary_tuning.F1(iv_index,:),secondary_tuning.F1_e(iv_index,:),secondary_color{iv_index});
            
        end
        
       
        figure(2),legend(leg,'Location','bestoutside')
        title(names(1).file_name)
        xlabel(subfields(1).primary)
        ylabel('Response(spikes/s)')
        saveas(gcf,[FigFileName '_secondary.fig']);
        
        figure(3),plot(tuning_data.PSTH_X, nanmean(tuning_data.PSTH))
        xlabel('Time(s)')
        ylabel('Response(spikes/s)')
        title(names(1).file_name)
        saveas(gcf,[FigFileName '_PSTH.fig']);
        primary_tuning.Type = subfields(1).secondary;
        secondary_tuning.Type = subfields(1).primary;
        
        
        
        
        tic
        
        if strcmp(primary_tuning.Type,'spa')
            
            spon = find(primary_tuning.IV2==0);
            if isempty(spon)
                spon = min(primary_tuning.F1(:));
            else
                spon = nanmean(nanmean(primary_tuning.F1(spon,:)));
            end
            primary_tuning.F1 = primary_tuning.F1 - spon;
            for iv_index = 1:size(primary_tuning.F1,1)
                 [fit_data(cn).param(iv_index,:),fit_data(cn).sf(iv_index,:),fit_data(cn).response(iv_index,:)]  = ...
                     LinearSuppression.fourier_dog_sf_single(primary_tuning.F1(iv_index,:)',primary_tuning.IV,spon);
                  fit_data(cn).con(iv_index) = primary_tuning.IV2(iv_index);
          
            end
            
        elseif strcmp(secondary_tuning.Type,'spa')
            spon = find(secondary_tuning.IV2==0);
            if isempty(spon)
                spon = min(secondary_tuning.F1(:));
            else
                spon = nanmean(nanmean(secondary_tuning.F1(spon,:)));
            end
            
            for iv_index = 1:size(secondary_tuning.F1,1)
                [fit_data(cn).param(iv_index,:),fit_data(cn).sf(iv_index,:),fit_data(cn).response(iv_index,:)]  = ...
                    LinearSuppression.fourier_dog_sf_single(secondary_tuning.F1(iv_index,:)',secondary_tuning.IV,spon);
%                 figure(100),plot(secondary_tuning.IV,secondary_tuning.F1(iv_index,:)','o')
%                 hold on
%                 plot(fit_data(cn).sf(iv_index,:),fit_data(cn).response(iv_index,:),'--')
%                 hold off
%                 fit_data(cn).param(iv_index,:)
%                 
                fit_data(cn).con(iv_index) = secondary_tuning.IV2(iv_index);
%                 pause
            end
            
            
            
        end
        fit_data(cn).param
      %  save(FileName,'tuning_data','primary_tuning','secondary_tuning','fit_data','-append')
        fprintf('File Save: time = %d',toc)
        z =fit_data(cn).con>5;
        figure(4),subplot(1,3,1),plot(fit_data(cn).con(z),fit_data(cn).param(z,2),'-o'), axis square
        ylabel('surround amplitude')
        xlabel('contrast')
        figure(4),subplot(1,3,2),plot(fit_data(cn).con(z),fit_data(cn).param(z,3),'-o'), axis square
        ylabel('center sigma')
        xlabel('contrast')
        figure(4),subplot(1,3,3),plot(fit_data(cn).con(z),fit_data(cn).param(z,4),'-o'), axis square
        ylabel('surround sigma')
        xlabel('contrast')
        
        saveas(gcf,[FigFileName '_FitParam.fig']);
        
        pause

        
        clear primary_tuning
        clear secondary_tuning
%       pause
 
    end
    
    
    
end








     