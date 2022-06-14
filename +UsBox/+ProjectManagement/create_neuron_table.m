function  [primary_id, neuron_list] = create_neuron_table(data_set,start_index,end_index,varargin)


T = readtable(data_set.ListFile,'FileType','spreadsheet','sheet',data_set.SpreadSheet);
[column_names,excel_data] =Spike2.get_excel_data(data_set,start_index, end_index);

recording_column = contains(column_names,'RecordingNumber');
recording_numbers = T.RecordingNumber;%cell2mat(excel_data(:,recording_column));
cell_column = contains(column_names,'CellNumber');
cell_numbers = cell2mat(excel_data(:,cell_column));
unique_recordings = unique(recording_numbers);
unique_cells = unique(cell_numbers);
Area_column = contains(column_names,'Area');
CellType_column = contains(column_names,'CellType');
polarity_column = contains(column_names,'OnOff');
cellname_column = contains(column_names,'CellName');
filename_column = contains(column_names,'FileName');
spikechannel_column = contains(column_names,'SpikeChannel');
continuouschannel_column = contains(column_names,'ContinuousChannel');
wm_column = contains(column_names,'WaveMark');
tr_column = contains(column_names,'TimeRange');
optolocation_column  = contains(column_names,'TimeRange');
primary_id = 0;
recording_id = 0;
h =fopen('C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/test_neuron_list.txt','w');
recording_h =fopen('C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/test_recording_list.txt','w');
opto_h =fopen('C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/test_opto_list.txt','w');
for recording_index = 1:length(unique_recordings)
    for cell_index = 1:length(unique_cells)
        current_rows = find(recording_numbers==unique_recordings(recording_index) & cell_numbers==unique_cells(cell_index));
        if ~isempty(current_rows)
            primary_id=primary_id+1;
            neuron_list(primary_id,:) = [primary_id unique_recordings(recording_index) unique_cells(cell_index)];
            current_area = excel_data{current_rows(1),Area_column};
            current_ct = excel_data{current_rows(1),CellType_column};
            current_polarity = excel_data{current_rows(1),polarity_column};
            current_project = 'CT Feedback';
            current_species = 'awake monkey';
            current_scientist = 'ans, hja';
            
            
            if strcmp(current_polarity,'V1')
                current_polarity = current_ct;
                current_ct = 'cx';
            end
            fprintf(h,'%d\t%s\t%s\t%s\t%s\t%s\t%s\n',primary_id,current_area,current_ct,current_polarity, current_project,...
                current_species, current_scientist);
            for file_index = 1:length(current_rows)
                recording_id=recording_id+1;
                current_file_name = [excel_data{current_rows(file_index),cellname_column} '_' excel_data{current_rows(file_index),filename_column}];
                current_spikechannel = excel_data{current_rows(file_index),spikechannel_column};
                current_continuouschannel = excel_data{current_rows(file_index), continuouschannel_column};
                current_wm = excel_data{current_rows(file_index),wm_column};
                current_tr = excel_data{current_rows(file_index),tr_column};
                
                fprintf(recording_h,'%d\t%d\t%s\t%d\t%d\t%d\t%s\n',recording_id,primary_id,current_file_name,...
                    current_spikechannel,current_wm,current_continuouschannel, current_tr);
                
                current_fiber_location = excel_data{current_rows(file_index),fiberl_column};
            end
            
            
        end
        
        
    end
    
end
fclose(h)
fclose(recording_h)