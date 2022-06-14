function TextID = convert_rgb(TextID)



tempstruct=squeeze(struct2cell(TextID.StimOn.FieldInfo));
[text_index.names,text_index.extents] =  regexp(tempstruct,'(?<red>\d*)/(?<green>\d*)/(?<blue>\d*)','names','tokenextents');

for index = 1:length(text_index.names)
    if ~isempty(text_index.names{index})
        red(index) =   str2num(text_index.names{index}.red);
        green(index) =   str2num(text_index.names{index}.green);
        blue(index) =   str2num(text_index.names{index}.blue);
    else
        red(index) =   nan;
        green(index) =   nan;
        blue(index) =   nan;
        
    end
    
end



if length(unique(red))>1
    IV = red;
    
elseif length(unique(green))>1
    IV = green;
else
    IV = blue;
    
end

%because of extraneous textmakers, some info needs to be removed.  These
%should be IV(index) = nan;
n=0;
for index = 1:length(TextID.StimOn.FieldInfo)
    if isfinite(IV(index))
        n=n+1;
        new_TextID.StimOn.FieldInfo(n).IV = num2str(IV(index));
        new_TextID.StimOn.timestamps(n) = TextID.StimOn.timestamps(index);
    end
    
    
end

TextID.StimOn = new_TextID.StimOn;