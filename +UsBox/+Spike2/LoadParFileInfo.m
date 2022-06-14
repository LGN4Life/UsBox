function Parameters = LoadParFileInfo(par_file)
Parameters.TargetList =[];

h = fopen(par_file);
rawParameters = textscan(h,'%s','Delimiter','\n');
rawParameters = rawParameters{1};
fclose(h);
current_heading = 'NonSpecific';

for index = 1:length(rawParameters)
    newHeading = regexp(rawParameters{index},'-----');
    if ~isempty(newHeading)
        
        current_heading = rawParameters{index-1};
        
        %change  case of characters after illegal characters
        illegalChacters =  regexp(current_heading,'[\s(),%#-/:?]');
        illegalChacters=illegalChacters(illegalChacters<length(current_heading));
        current_heading(illegalChacters+1) = upper(current_heading(illegalChacters+1));
        
        %remove illegal characters from heading
        legalCharacters =  regexp(current_heading,'[^\s(),%#-/:?]');
        current_heading(illegalChacters+1) = upper(current_heading(illegalChacters+1));
        current_heading = current_heading(legalCharacters);
        
        
    end
    if contains(current_heading, 'Targets')
        
        if ~contains(rawParameters{index},' SUCCESS FAIL')
            [current_target,e] =regexp(rawParameters{index},'(\s*(?<x>-*\d*\.\d*),\s*(?<y>-*\d*\.\d*)','names','tokenExtents');
            if ~isempty(current_target)
                current_target = [str2num(current_target.x) str2num(current_target.y)];
                Parameters.TargetList= cat(1,Parameters.TargetList, current_target);
          
                
                
            end
            
            
        end
        
        
    else
        varBreakIndex =  regexp(rawParameters{index},':[^\\]');
        if length(varBreakIndex)==1
            
            [varValue, varName] = ProcessStrings(rawParameters{index},varBreakIndex);
            Parameters.(current_heading).(varName) = varValue;
        elseif length(varBreakIndex) == 2
            varBreakIndex = varBreakIndex(2);
            [varValue, varName] = ProcessStrings(rawParameters{index},varBreakIndex);
            Parameters.(current_heading).(varName) = varValue;
            
        end
        
        
        
    end
   
    
    
    
end












function [varValue, varName] = ProcessStrings(rawParameters,varBreakIndex);

varName = rawParameters(1:varBreakIndex-1);

%change  case of characters after illegal characters
illegalChacters =  regexp(varName,'[\s(),%#-/:?]');
illegalChacters=illegalChacters(illegalChacters<length(varName));
varName(illegalChacters+1) = upper(varName(illegalChacters+1));

%remove illegal characters from variable name

legalChacters =  regexp(varName,'[^\s(),%#-/:?]');


varName = varName(legalChacters);

varValue = rawParameters(varBreakIndex+1:end);

%remove illegal characters from variable value
legalChacters =  regexp(varValue,'[^\s]');

varValue = varValue(legalChacters);

