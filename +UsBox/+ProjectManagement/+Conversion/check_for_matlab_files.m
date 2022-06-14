function [missing_files] = check_for_matlab_files(start_index, end_index)


ListFile = 'C:\Henry\FileLists\ConvertToSQL.xlsx';

original_matlab_directory = 'D:\\AwakeData\\DataStruct\\';
new_matlab_directory = 'D:\\AwakeData\\Matlab\\';

%retreive list of spreadsheets to add to database
[SpreadSheets, SSRange] = ProjectManagement.Conversion.spreadsheet_list;


missing_files = {};
for ss_index = start_index:end_index%length(SpreadSheets)
    ss_index
    fprintf('Loading spreadsheet: %s\n', SpreadSheets{ss_index})
    
    excel_table = ProjectManagement.Conversion.load_from_excel(ListFile,SpreadSheets{ss_index},SSRange(ss_index,:));
    
    for file_index = 1:size(excel_table,1)
        if excel_table.Exclude(file_index)==0
            original_file_name = [original_matlab_directory  excel_table.CellName{file_index} '_', excel_table.FileName{file_index} '_' num2str(excel_table.RecordingNumber(file_index)) '_' num2str(excel_table.CellNumber(file_index)) '.mat'];
            
            if 1==1%exist(original_file_name','file') ==0
                fprintf([original_file_name ' does not exist, now creating from ' SpreadSheets{ss_index}  ' at index ' num2str(file_index) '\n'])
                ExcelInput = table2struct(excel_table(file_index,:));
                [missing_flag,missing_file_name] = ProjectManagement.Conversion.load_from_spike2( ExcelInput);
            
                if missing_flag==0
                   missing_files = cat(1,missing_files, missing_file_name);
                   fprintf('missing file count = %d\n',length(missing_files))
                 
                end
            end
        end
    end
    
    
    
    
    
    
end