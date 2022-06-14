function [data_set,data_path] = load_data_set(project_name)


directory_file = "C:\Henry\FileLists\Matlab\Projectlocations.txt";
fileID = fopen(directory_file);
rawParameters = textscan(fileID,'%s %s %s','delimiter','\t');

project_location = regexp(rawParameters{1},project_name);
project_location = find(~cellfun(@isempty,project_location));

if ~isempty(project_location)
    data_set = rawParameters{3}{project_location};
    data_path = rawParameters{2}{project_location};
    load(data_path,data_set);
    data_set = eval(data_set);
else
   fprintf('project %s not found', project_name); 
    data_path = 'project not found';
    data_set = [];
    
    
end
    

