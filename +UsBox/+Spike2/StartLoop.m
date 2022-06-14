function LoopVar = StartLoop(data_set,input)

%this is called by functions to start looping through excel spreadsheet
%data



if length(input)>=1
    LoopVar.start_index = input{1};
else
    LoopVar.start_index = data_set.ExcelRange(1);
end

if length(input)>=2
    LoopVar.end_index = input{2};
else
    
    LoopVar.end_index = data_set.ExcelRange(2); 
end

if length(input)>=3
    LoopVar.file_type = input{3};
else
    
    LoopVar.file_type = 'any'; 
end

if length(input)>=4
    LoopVar.opto = input{4};
else
    
    LoopVar.opto = false; 
end










[LoopVar.column_names,LoopVar.excel_data] =Spike2.get_excel_data(data_set,LoopVar.start_index, LoopVar.end_index);
%Utilities.GetExcelInput(obj,[start_index end_index],ColumnNames)
LoopVar.true_row_index = LoopVar.start_index:LoopVar.end_index;
LoopVar.end_index = size(LoopVar.excel_data,1);
LoopVar.start_index = 1;