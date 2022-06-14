function excel_to_sql_conversion(conn,database_files,start_index, end_index, duplication_flag)
%use this function to take existing spreadsheets and load them into an sql
%database

%Once the database is created, this function (and similar functions) will
%no longer be used. New data will be loaded into the data bases using more
%efficent methods

%depending on the data being loaded, these parameters should be updated


[excel_data,read_time] = UsBox.Spike2.get_excel_data(database_files,start_index, end_index);
if duplication_flag
    excel_data =UsBox.ProjectManagement.SQL.duplication_check(excel_data,conn);
end


if ~isempty(excel_data)
    %create neuron table
    if sum(strcmp('SpikeChannel',excel_data.Properties.VariableNames))>0 || sum(strcmp('ContinuousChannel',excel_data.Properties.VariableNames))>0
        [neuron_table, excel_data] = UsBox.ProjectManagement.Conversion.create_neuron_table(excel_data,conn);
        
        sqlwrite(conn,'neurons',neuron_table)
    end
    
    %create file table
    [file_table, excel_data] = UsBox.ProjectManagement.Conversion.create_file_table(excel_data,conn);
    
    sqlwrite(conn,'files',file_table,'Catalog','learning')
    
    %create recording table
    if sum(strcmp('SpikeChannel',excel_data.Properties.VariableNames))>0 || sum(strcmp('ContinuousChannel',excel_data.Properties.VariableNames))>0
        [recording_table, excel_data,continuous_table] = UsBox.ProjectManagement.Conversion.create_recording_table(excel_data,conn);
        
        sqlwrite(conn,'continuous',continuous_table)
        sqlwrite(conn,'recordings',recording_table)
        
    end
    
    
    %create opto table
    if sum(strcmp('Opsin',excel_data.Properties.VariableNames))>0
        [opto_table] = UsBox.ProjectManagement.Conversion.create_opto_table(excel_data);
        sqlwrite(conn,'opto',opto_table)
    end
    % UsBox.ProjectManagement.Conversion.reformat_matlab_data(excel_data)
    
end

end



