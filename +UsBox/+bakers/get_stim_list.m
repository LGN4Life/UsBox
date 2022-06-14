function stim_list = get_stim_list(s)
%takes string of stimulus parameters and constructs the stimulus list

stim_id = [{'--wh'},{'-Z'}, {'-O'},{'-C'},{'-S'},{'-P'},{'-T'}];
stim_name = [{'size'},{'xy'},{'ori'},{'con'},{'sf'},{'phase'},{'tf'}];
for index = 1:length(stim_id)
    stim_list.(stim_name{index}) = [];
    current_exp = ['(' stim_id{index} '(-*\d*\.*\d*,*)+)'];
    m = cell2mat(regexp(s,current_exp,'tokenExtents'));
    if ~isempty(m)
        current_s = s(m(1):m(2));
       [n,e] = regexp(current_s,'(?<IV>-?\d+\.?\d*),?','names','tokenExtents');
       temp = struct2cell(n);
       stim_list.(stim_name{index}) = squeeze(cellfun(@str2num,temp));
    
    end
end

stim_list.size = reshape(stim_list.size,2,length(stim_list.size)/2)';
stim_list.xy = reshape(stim_list.xy,2,length(stim_list.xy)/2)';
%find parameter markers
