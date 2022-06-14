function  [neuron_table, recording_table] = excel_to_sql_conversion(data_set,start_index,end_index,varargin)
%use this function to take existing spreadsheets and load them into an sql
%database

%Once the database is created, this function (and similar functions) will
%no longer be used. New data will be loaded into the data bases using more
%efficent methods

%depending on the data being loaded, these parameters should be updated
current_project = 'CT Feedback';
current_species = 'awake monkey';
current_scientist = 'ans, hja';
current_opsin = {'dlx-chr2'};

%%
%read data from excel
ExcelLine = 'a1:az1';

%housework to read in data
[~,~,column_names] =xlsread(data_set.ListFile,data_set.SpreadSheet,ExcelLine);
name_length = cellfun(@length,column_names);
column_number = find(name_length==1,1,'first')-1;
column_names=column_names(1:column_number);
last_column_letter = Utilities.num2letter(column_number);

ExcelLine = ['a' num2str(start_index) ':' last_column_letter num2str(end_index)];



excel_table = readtable(data_set.ListFile,'FileType','spreadsheet','sheet',data_set.SpreadSheet,'Range',ExcelLine);

%if one is not reading in the entire sheet, getting the variable names from
%the first row is tricky. Set it manualy.
excel_table.Properties.VariableNames = column_names;
%%



unique_recordings = unique(excel_table.RecordingNumber);
unique_cells = unique(excel_table.CellNumber);

cn=0;

recording_id = 1:size(excel_table,1);
neuron_fk = nan(1,size(excel_table,1));

for recording_index = 1:length(unique_recordings)
    for cell_index = 1:length(unique_cells)
        current_rows = find(excel_table.RecordingNumber==unique_recordings(recording_index) & excel_table.CellNumber==unique_cells(cell_index));
        
        if ~isempty(current_rows)
            
            cn=cn+1;
            neuron_fk(current_rows) =cn;
            neuron_id(cn,1) = cn;
            species{cn,1} = current_species;
            animal_name{cn,1} = excel_table.AnimalName{current_rows(1)};
            brain_areas{cn,1} = excel_table.Area{current_rows(1)};
            cell_types{cn,1} = excel_table.CellType{current_rows(1)};
            polarities{cn,1} = excel_table.OnOff{current_rows(1)};
            project{cn,1} = current_project;
            scientist{cn,1} = current_scientist;
            
            
            
            if strcmp(polarities{cn,1},'V1')
                polarities{cn,1} = cell_types{cn,1};
                cell_types{cn,1} = 'cx';
            end
            
            
        end
        
        
    end
    
end

%write neuron table to file
neuron_table = table(neuron_id, species, animal_name,brain_areas,cell_types,polarities,...
    project, scientist, 'VariableNames',{'NeuronID','Species','AnimalName','BrainArea','CellType','Polarity'...
    'Project','RecordedBy'});

writetable(neuron_table,'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\test_neuron_list.txt','Delimiter','\t')

%write recording table to file
excel_table.FileName = strcat(excel_table.CellName, '_', excel_table.FileName);
recording_table = table(recording_id',neuron_fk',excel_table.FileName,excel_table.SpikeChannel,excel_table.WaveMark,...
    excel_table.WaveMarkGrade,excel_table.ContinuousChannel,excel_table.TimeRange,excel_table.Exclude);
recording_table.Properties.VariableNames = {'RecordingId', 'NeuronId', 'FileName', 'SpikeChannel', 'WaveMark',...
    'WaveMarkGrade','ContinuousChannel', 'TimeRange','Exclude'};

writetable(recording_table,'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\test_recording_list.txt','Delimiter','\t')

%write opto table to file
current_opsin = repmat(current_opsin,length(recording_id),1);
opto_table = table(recording_id',neuron_fk',excel_table.FileName,current_opsin, excel_table.FiberLocation,excel_table.OptoRF,...
    excel_table.OptoRating,excel_table.LaserLevel);
opto_table.Properties.VariableNames = {'recording_id', 'neuron_id', 'FileName', 'Opsin', 'FiberLocation', 'FiberRF',...
    'OptoRating', 'LaserLevel'};
writetable(opto_table,'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\test_opto_list.txt','Delimiter','\t')




