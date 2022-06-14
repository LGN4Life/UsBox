function reformat_matlab_data(excel_table)

original_matlab_directory = 'D:\AwakeData\DataStruct\';
new_matlab_directory = 'D:\AwakeData\Matlab\';
for file_index = 1:size(excel_table,1)

    if excel_table.Exclude(file_index)==0
        original_file_name = [original_matlab_directory  excel_table.CellName{file_index} '_', excel_table.FileName{file_index} '_' num2str(excel_table.RecordingNumber(file_index)) '_' num2str(excel_table.CellNumber(file_index)) '.mat'];
        new_folder_name = [excel_table.CellName{file_index} '_', excel_table.FileName{file_index}];
        original_file_name
        if ~exist(original_file_name','file')
            ExcelInput = table2struct(excel_table(file_index,:));
           ProjectManagement.Conversion.load_from_spike2( ExcelInput) 
        end
        clear data
        clear continuous_recording
        load(original_file_name,'data','continuous_recording','pupil_data')
        
        folder_name =  [new_matlab_directory new_folder_name] ;
        
        %check to see if directory exists, if not create
        if ~exist(folder_name,'file')
            mkdir(folder_name)
        end
        
        if sum(strcmp('SpikeChannel',excel_table.Properties.VariableNames))>0
            if excel_table.SpikeChannel(file_index)>0
                spike_file_name = [ folder_name '\spike_channel_' num2str(excel_table.SpikeChannel(file_index)) '_' num2str(excel_table.WaveMark(file_index))];
                spike_times = data.SpikeData.RawSpikeTimes;
                save(spike_file_name,'spike_times')
            end
        end
        if ~isempty(pupil_data)
            pupil_file_name = [ folder_name '\pupil_data'];
            save(pupil_file_name,'pupil_data')
        end
        
        if sum(strcmp('ContinuousChannel',excel_table.Properties.VariableNames))>0
            if excel_table.ContinuousChannel(file_index)>0
                continuous_file_name = [ folder_name '\continuous_channel_' num2str(excel_table.ContinuousChannel(file_index))];
                continuous_recording = continuous_recording;
                save(continuous_file_name,'continuous_recording')
            end
        end
        
        parameters = data.Parameters;
        if contains(original_file_name,'dark') | contains(original_file_name,'ps') | contains(original_file_name,'imgs')...
                | contains(original_file_name,'vid')
            TrialParameters =[];
            CompletedTrials = [];
        elseif contains(original_file_name,'atn')
            if contains(original_file_name,'18') | contains(original_file_name,'19') |contains(original_file_name,'20')...
                    | contains(original_file_name,'21')
                [TrialParameters,CompletedTrials] = Attention.TextKeyExtract(parameters);
            else
              [TrialParameters,CompletedTrials] = Attention_2014.TextKeyExtract(parameters);  
            end
            
        elseif contains(original_file_name,'star')
            [TrialParameters,CompletedTrials] = StarStim.TextKeyExtract(parameters);
        else
            [TrialParameters,CompletedTrials] = AlertTuning.TextKeyExtract(parameters);
        end
       
        
        save([folder_name '\parameters'],'parameters','TrialParameters','CompletedTrials')
        % neuron_file_name = excel_table.
      
    end
    
end