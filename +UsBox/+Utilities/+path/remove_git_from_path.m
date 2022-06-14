function full_path  = remove_git_from_path
%removes "git" folders from the matlab path
linear_path = path;

d = strfind(path,'C:\');
git_index = 0;
index=1;

length(d)

for index = 1: length(d)
    
    if index == length(d)
        
        full_path{index} = linear_path(d(index):end);
        break
    end
    
    full_path{index} = linear_path(d(index):d(index+1)-1);

    
    
    if contains(full_path{index},'git')
        rmpath(full_path{index})
        full_path{index}=[];
    end
        
    
end
length(full_path)





