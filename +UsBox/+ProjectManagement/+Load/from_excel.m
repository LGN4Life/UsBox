function excel_table = from_excel(ListFile,SpreadSheet, SSRange)

load('C:\Henry\MatlabScripts\Directories','Directories')
ExcelDirectory = Directories.Excel;
MatlabDirectory = Directories.Matlab;

excel_table = ProjectManagement.Load.excel_prep([ExcelDirectory ListFile],SpreadSheet,SSRange);


for index = 1:size(excel_table,1)
    ExcelInput = table2struct(excel_table(index,:));
    [data,continuous_recording,eye_pos,pupil_data] = ProjectManagement.Load.from_spike2(ExcelInput);
    
    file_parameters = data.Parameters;
    folder_name =  [MatlabDirectory excel_table.FileName{index}] ;
    
    %check to see if directory exists, if not create
    if ~exist(folder_name,'file')
        mkdir(folder_name)
    end
    
    if contains(ExcelInput.FileType,'attention')
        
        [psycho,TrialParameters] =  Attention.Psycho.Calculate(file_parameters,eye_pos);
        
        save([ folder_name '\psycho'],'psycho')
        save([ folder_name '\trial_parameters'],'TrialParameters')
        TargetNumber = str2num(file_parameters.TuningParameters.NumberOfDistractors);
        attention_table = table(TargetNumber);
        if sum(strcmp('AttentionRFLoc',excel_table.Properties.VariableNames))>0
            RFPosition =  excel_table.AttentionRFLoc(index);
            attention_table = addvars(attention_table,RFPosition);
        end
        pause
    end
    
    if sum(strcmp('SpikeChannel',excel_table.Properties.VariableNames))>0
        if excel_table.SpikeChannel(index)>0
            spike_file_name = [ folder_name '\spike_channel_' num2str(excel_table.SpikeChannel(index))];
            spike_times = data.SpikeData.RawSpikeTimes;
            save(spike_file_name,'spike_times')
        end
    end
    
    if sum(strcmp('ContinuousChannel',excel_table.Properties.VariableNames))>0
        if excel_table.ContinuousChannel(index)>0
            continuous_file_name = [ folder_name '\continuous_channel_' num2str(excel_table.ContinuousChannel(index))];
            continuous_recording = continuous_recording;
            save(continuous_file_name,'continuous_recording')
        end
    end
    
    
    save([folder_name '\file_parameters'],'file_parameters')
    
    
    
    
end