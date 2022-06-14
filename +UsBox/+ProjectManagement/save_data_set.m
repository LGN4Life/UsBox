function project_directory = save_data_set(project_name,data_set,project_directory)


directory_file = "C:\Henry\FileLists\Matlab\Projectlocations.txt";
fileID = fopen(directory_file);

%load directory info from file
rawParameters = textscan(fileID,'%s %s %s','delimiter','\t');

%determine if the project exists andhas been previously saved



project_location = regexp(rawParameters{1},project_name);
project_location = find(~cellfun(@isempty,project_location));


if ~isempty(project_location)
    %project exists
    %update info in rawParameters to be updated to the file
    
    data_set = rawParameters{3}{project_location};
    data_path = rawParameters{2}{project_location};
    load(data_path,data_set);
    data_set = eval(data_set);
else
    fprintf('project %s not found', project_name);
    data_path = 'project not found';
    data_set = [];
    
    
end










temp_file = fopen('C:\Henry\MatlabScripts\CurrentProjects\+ProjectManagement\temp.txt','w');
for line_index = 1:length(rawParameters{1})
    fprintf(temp_file,'%s\t%s\t%s\n', rawParameters{1}{line_index},rawParameters{2}{line_index},rawParameters{3}{line_index});


end
fclose(temp_file)


