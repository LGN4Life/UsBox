function excel_table = check_for_new_files(ListFile,SpreadSheet,SSRange,conn)


excel_table = ProjectManagement.Conversion.load_from_excel(ListFile,SpreadSheet,SSRange);


file_table = sqlread(conn,'files');



duplicates = ismember(excel_table.FileName,file_table.FileName);
    fprintf('%d new files found \n',sum(~duplicates));
    
excel_table(duplicates,:) = [];
 
 
 
 