function [data_struct] = GetParameters(data_set,file_index,ColumnNames)
ColumnLetters = Utilities.num2letter(26);

ExcelLine = ['a' num2str(file_index) ':' ColumnLetters num2str(file_index)];

[num,txt,ExcelInput] =xlsread(data_set.ListFile,data_set.SpreadSheet,ExcelLine);


data_struct.Parameters.ExcelData = data_set.InitializeExcelDataStruct;

data_struct = data_set.LoadDataStructParameters(ColumnNames,ExcelInput);







