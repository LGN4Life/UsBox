function data = DetermineDirectoryNames(data_set,ExcelInput)



data.Parameters.DataBase = ExcelInput;


%write file directories


%%
%where are the *.mat files stored. Data extracted from the spike2 SMR
%files is placed in a data structure that is located in a *.mat file
%the directory of that location is determined by the experiment info
%supplied by the user: data_set.MatlabDirectory. data_set.MatlabDirectory
%contains a string that specifies the directory where the data structs are
%saved
data.Parameters.FileNames.MatLab = [data_set.MatlabDirectory ExcelInput.FileName{:} '_' num2str(ExcelInput.RecordingNumber)]; 



%%
%there are three files loaded from data collection, all stored in
%data_set.Spike2Directory:
%smr, eyd (pupil data), and par (text file of exp parameters). All can be
%accessed by adding the extention onto data.Parameters.FileNames.Spike2
if sum(strcmp(data.Parameters.DataBase.Properties.VariableNames,'AnimalName'))>0
    base_directory = [data_set.Spike2Directory data.Parameters.DataBase.AnimalName{:} '\'];
else
    base_directory = [data_set.Spike2Directory '\'];
end
%if the files are seperated into recording dates 
if sum(strcmp(data.Parameters.DataBase.Properties.VariableNames,'MainFolder'))>0
    base_directory = [base_directory num2str(data.Parameters.DataBase.MainFolder) '\'];

end

%when multielectrode data is collected in spike2, the recordings may be
%seperated into mutiple files (because of Spike2 channel limits). When this
%happens data.Parameters.DataBase.FileName is a reference to the channel
%specific smr file. In this case the data.Parameters.DataBase.FileName
%will contain a ch{channelnumber} (eg., area_000_ch1 or area_000_ch2)
%For all files, we will store a data.Parameters.FileNames.Spike2 and a
%data.Parameters.FileNames.Spike2ParChan (which contains triggers and
%such). For must files these will be the same, but for plexon type data
%they will be different.

data.Parameters.FileNames.Spike2 =  [base_directory data.Parameters.DataBase.FileName{:}];
if ~isempty(strfind(data.Parameters.FileNames.Spike2,'_ch'))
    string_index = strfind(data.Parameters.FileNames.Spike2,'_ch');
    
    data.Parameters.FileNames.Spike2ParChan = [data.Parameters.FileNames.Spike2(1:string_index-1)];

    
else
    
    data.Parameters.FileNames.Spike2ParChan = [data.Parameters.FileNames.Spike2];
 
end


%(to access the par file: [data.Parameters.FileNames.Spike2ParChan '.par']
















