function excel_table = excel_prep(ListFile,SpreadSheet,SSRange)


%read data from excel
ExcelLine = 'a1:az1';

%housework to read in data
[~,~,column_names] =xlsread(ListFile,SpreadSheet,ExcelLine);
name_length = cellfun(@length,column_names);
column_number = find(name_length==1,1,'first')-1;
column_names=column_names(1:column_number);
last_column_letter = Utilities.num2letter(column_number);

ExcelLine = ['a' num2str(SSRange(1)) ':' last_column_letter num2str(SSRange(2))];



excel_table = readtable(ListFile,'FileType','spreadsheet','sheet',SpreadSheet,'Range',ExcelLine);


%if one is not reading in the entire sheet, getting the variable names from
%the first row is tricky. Set it manualy.
excel_table.Properties.VariableNames = column_names;