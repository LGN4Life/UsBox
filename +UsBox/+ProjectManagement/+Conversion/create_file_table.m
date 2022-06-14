function [file_table, excel_table] = create_file_table(excel_table,conn)



table_name = 'files';
value_name = 'FileID';
m_fileID = UsBox.ProjectManagement.get_max_value(table_name,value_name,conn);


new_file_names = excel_table.FileName;
[unique_filennames,excel_id,FileID] = unique(new_file_names,'stable');
excel_table = addvars(excel_table,FileID+m_fileID,'NewVariableNames','FileID');

file_table = table(m_fileID+[1:length(unique_filennames)]',unique_filennames,'VariableNames',{'FileID','FileName'});



file_table = addvars(file_table,excel_table.Project(excel_id),'NewVariableNames','Project');
file_table = addvars(file_table,excel_table.Scientist(excel_id),'NewVariableNames','Scientist');
file_table = addvars(file_table,excel_table.Species(excel_id),'NewVariableNames','Species');
file_table = addvars(file_table,excel_table.AnimalName(excel_id),'NewVariableNames','AnimalName');
