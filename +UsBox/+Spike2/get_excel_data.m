function [excel_data,read_time] = get_excel_data(obj,start_index,end_index)
%reads in excel data
%output: column_names are taken from the first row of the excel file
%will be used by matlab to make sense of the excel data (e.g., to construct
%the file names.


tic
opts = detectImportOptions(obj.ListFile,'Sheet',obj.SpreadSheet,'ReadVariableNames',true,'DataRange',[num2str(start_index) ':' num2str(end_index)],'VariableNamesRange','1:1');
excel_data  =  readtable(obj.ListFile,opts);
read_time = toc;



