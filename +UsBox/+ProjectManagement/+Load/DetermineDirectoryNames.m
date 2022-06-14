function data = DetermineDirectoryNames(data_table,data_set)


data.Parameters.DataBase = table2struct(data_table);



data.Parameters.FileNames.Spike2 =  [data_set.Spike2Directory data.Parameters.DataBase.AnimalName '\'];
RootFileName = [data.Parameters.DataBase.FileName ];

data.Parameters.FileNames.Eyd = [data.Parameters.FileNames.Spike2 RootFileName '.eyd'];
data.Parameters.FileNames.Spike2 = [data.Parameters.FileNames.Spike2 RootFileName '.smr'];






if ~isempty(strfind(data.Parameters.FileNames.Spike2,'_ch'))
    string_index = strfind(data.Parameters.FileNames.Spike2,'_ch');
    
    data.Parameters.FileNames.ParFile = [data.Parameters.FileNames.Spike2(1:string_index-1) '.par'];
    data.Parameters.FileNames.Spike2ParChan = [data.Parameters.FileNames.Spike2(1:string_index-1) '.smr'];
    

    
else
    
    string_index = strfind(data.Parameters.FileNames.Spike2,'.smr');
    
    data.Parameters.FileNames.ParFile = [data.Parameters.FileNames.Spike2(1:string_index-1) '.par'];
    
    data.Parameters.FileNames.Spike2ParChan =[];
    data.Parameters.FileNames.Spike2ParChan =data.Parameters.FileNames.Spike2;
 
end


data.Parameters.FileNames.MatLab = [data_set.MatlabDirectory RootFileName '\'];

if ~exist(data.Parameters.FileNames.MatLab,'dir')
    mkdir(data.Parameters.FileNames.MatLab)
    fprintf('created new directory %s\n',data.Parameters.FileNames.MatLab)
end







