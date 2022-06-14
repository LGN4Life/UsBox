function data = LoadMSeqParFileInfo(data)

rawParameters = textread(data.Parameters.FileNames.ParFile,'%s','whitespace','\n','bufsize',40000);


for index = 1:length(rawParameters)
  

    
    
    varBreakIndex =  regexp(rawParameters{index},'"');
    if length(varBreakIndex)==1
        
        [varValue, varName] = ProcessStrings(rawParameters{index},varBreakIndex);
        data.Parameters.MSeq.(varName) = varValue;
    elseif length(varBreakIndex) == 2
        varBreakIndex = varBreakIndex(2);
        [varValue, varName] = ProcessStrings(rawParameters{index},varBreakIndex);
        data.Parameters.MSeq.(varName) = str2num(varValue);
        
    end
    
    
    
end













function [varValue, varName] = ProcessStrings(rawParameters,varBreakIndex);

varName = rawParameters(1:varBreakIndex);

%change  case of characters after illegal characters
illegalChacters =  regexp(varName,'[\s(),%#-/:?"]');
illegalChacters=illegalChacters(illegalChacters<length(varName));
varName(illegalChacters+1) = upper(varName(illegalChacters+1));

%remove illegal characters from variable name

legalChacters =  regexp(varName,'[^\s(),%#-/:?"]');


varName = varName(legalChacters);

varValue = rawParameters(varBreakIndex+1:end);

%remove illegal characters from variable value
legalChacters =  regexp(varValue,'[^\s]');

varValue = varValue(legalChacters);

