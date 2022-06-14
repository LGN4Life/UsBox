function excel_table = duplication_check(excel_table,conn)


neuron_table = sqlread(conn,'neurons');
file_table = sqlread(conn,'files');

duplicates = false(1,length(excel_table.FileName));
if isempty(neuron_table)
    fprintf('Database is empty, no duplications found');
else
    
    for index = 1:length(excel_table.FileName)
        
        new_file_name = [excel_table.FileName{index}];
        
        duplicates(index) = ismember(new_file_name,file_table.FileName);
    end
    
    
    
    if sum(duplicates)>0
        
        fprintf('%d new records found, %d duplicates found and removed \n',sum(~duplicates),sum(duplicates));
        excel_table(duplicates,:) = [];
        
    end
    
end



