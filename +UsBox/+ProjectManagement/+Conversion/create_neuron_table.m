function [neuron_table, excel_table] = create_neuron_table(excel_table,conn)

%determine unique new cells for list
unique_recordings = unique(excel_table.RecordingNumber);
unique_cells = unique(excel_table.CellNumber);

%preallocate variable to hold NeuronID foreign key that will be used for
%the recording table
neuron_fk = nan(1,size(excel_table,1));

%determine what is the last value used (max) for NeuronID in the database
table_name = 'neurons';
value_name = 'NeuronID';
cn = UsBox.ProjectManagement.get_max_value(table_name,value_name,conn);
row_num=0;

for recording_index = 1:length(unique_recordings)
    for cell_index = 1:length(unique_cells)
        current_rows = find(excel_table.RecordingNumber==unique_recordings(recording_index) & excel_table.CellNumber==unique_cells(cell_index));
        
        if ~isempty(current_rows)
            
            cn=cn+1;
            row_num = row_num+1;
            neuron_fk(current_rows) =cn;
            NeuronID(row_num,1) = cn;
            animal_name{row_num,1} = excel_table.AnimalName{current_rows(1)};
            brain_areas{row_num,1} = excel_table.Area{current_rows(1)};
            cell_types{row_num,1} = excel_table.CellType{current_rows(1)};
            polarities{row_num,1} = excel_table.OnOff{current_rows(1)};
      
            
            
      
            
            
        end
        
        
    end
    
end

neuron_table = table(NeuronID, brain_areas,cell_types,polarities, 'VariableNames',{'NeuronID','BrainArea','CellType','Polarity'});

excel_table = addvars(excel_table,neuron_fk','NewVariableNames','NeuronID');
