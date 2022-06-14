function fhand = OpenSmrFile(file_name)

%this allows the spike2 file to be an *.smr or a *.smrx
if ~exist(file_name,'file')
    display('.smr file does not exist, switch extention to .smrx')
    ex_index = strfind(file_name,'.smr');
    file_name = [file_name(1:ex_index) 'smrx'];
    if ~exist(file_name,'file')
        error([file_name ' does not exist']);
    end
end

fhand = CEDS64Open(file_name);