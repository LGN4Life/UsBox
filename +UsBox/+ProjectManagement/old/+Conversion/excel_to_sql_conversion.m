function  [neuron_table, recording_table] = excel_to_sql_conversion(data_set,start_index,end_index,varargin)
%use this function to take existing spreadsheets and load them into an sql
%database

%Once the database is created, this function (and similar functions) will
%no longer be used. New data will be loaded into the data bases using more
%efficent methods

%depending on the data being loaded, these parameters should be updated



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



%determine what is the last value used (max) for NeuronID in the database
table_name = 'neurons';
value_name = 'NeuronID';
cn = ProjectManagement.get_max_value(table_name,value_name);

table_name = 'recordings';
value_name = 'RecordingID';
m_recordingID = ProjectManagement.get_max_value(table_name,value_name);

table_name = 'files';
value_name = 'FileID';
m_fileID = ProjectManagement.get_max_value(table_name,value_name);

neuron_fk = nan(1,size(excel_table,1));

excel_table.FileName = strcat(excel_table.CellName, '_', excel_table.FileName);
[unique_filennames,~,FileID] = unique(excel_table.FileName,'stable');
excel_table = addvars(excel_table,FileID+m_fileID,'NewVariableNames','FileID');

RecordingID = m_recordingID+[1:length(excel_table.CellName)]';
excel_table = addvars(excel_table,RecordingID+m_recordingID,'NewVariableNames','RecordingID');


file_table = table(m_fileID+[1:length(unique_filennames)]',unique_filennames,'VariableNames',{'FileID','FileName'});
row_num = 0;
for recording_index = 1:length(unique_recordings)
    for cell_index = 1:length(unique_cells)
        current_rows = find(excel_table.RecordingNumber==unique_recordings(recording_index) & excel_table.CellNumber==unique_cells(cell_index));
        
        if ~isempty(current_rows)
            
            cn=cn+1;
            row_num = row_num+1;
            neuron_fk(current_rows) =cn;
            NeuronID(row_num,1) = cn;
            species{row_num,1} = excel_table.Species{current_rows(1)};
            animal_name{row_num,1} = excel_table.AnimalName{current_rows(1)};
            brain_areas{row_num,1} = excel_table.Area{current_rows(1)};
            cell_types{row_num,1} = excel_table.CellType{current_rows(1)};
            polarities{row_num,1} = excel_table.Area{current_rows(1)};
            project{row_num,1} = excel_table.Species{current_rows(1)};
            scientist{row_num,1} = excel_table.Project{current_rows(1)};
            
            
            
            if strcmp(polarities{row_num,1},'V1')
                polarities{row_num,1} = cell_types{row_num,1};
                cell_types{row_num,1} = 'cx';
            end
            
            
        end
        
        
    end
    
end

excel_table = addvars(excel_table,neuron_fk','NewVariableNames','NeuronID');

%write neuron table to file
neuron_table = table(NeuronID, species, animal_name,brain_areas,cell_types,polarities,...
    project, scientist, 'VariableNames',{'NeuronID','Species','AnimalName','BrainArea','CellType','Polarity'...
    'Project','RecordedBy'});

writetable(neuron_table,'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\neurons.txt','Delimiter','\t')
%write recording table to file

recording_table = table(RecordingID,neuron_fk',excel_table.FileID,excel_table.SpikeChannel,excel_table.WaveMark,...
    excel_table.WaveMarkGrade,excel_table.ContinuousChannel,excel_table.TimeRange,excel_table.Exclude);
recording_table.Properties.VariableNames = {'RecordingID','NeuronId', 'FileID', 'SpikeChannel', 'WaveMark',...
    'WaveMarkGrade','ContinuousChannel', 'TimeRange','Exclude'};

writetable(recording_table,'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\recordings.txt','Delimiter','\t')




if sum(strcmp('Opsin',excel_table.Properties.VariableNames))>0
    %write opto table to file
    opto_table = table(excel_table.FileID,excel_table.Opsin, excel_table.FiberLocation,excel_table.FiberRF,...
        excel_table.LaserWavelength);
    opto_table.Properties.VariableNames = {'FileID', 'Opsin', 'FiberLocation', 'FiberRF',...
        'LaserColor'};
    writetable(opto_table,'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\opto.txt','Delimiter','\t')
end
% 
writetable(file_table,'C:\ProgramData\MySQL\MySQL Server 8.0\Uploads\files.txt','Delimiter','\t')



