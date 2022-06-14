function [ExcelData] = BuildExcelDataField(ColumnNames,excel_line_data)



for index=1:length(ColumnNames)
 
    ExcelData.(ColumnNames{index}) = cell2mat(excel_line_data(index));
   
end








