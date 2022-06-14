function data_set = DataSet(varargin)
if length(varargin)>=1
    fileDirList = varargin{1};
    
    
    rawTxt = textread(fileDirList,'%s','whitespace','\n','bufsize',40000);
    
    for index = 1:length(rawTxt)
        
        BreakIndex =  regexp(rawTxt{index},':[^\\]');
        fieldName = rawTxt{index}(1:BreakIndex-1);
        %remove white spaces
        legalChacters =  regexp(fieldName,'[^\s]');
        fieldName = fieldName(legalChacters);
        
        dirName = rawTxt{index}(BreakIndex+1:end);
        
        
        legalCharacters =  regexp(dirName,'[^\s]');
        dirName = dirName(legalCharacters);
        
        data_set.(fieldName) = dirName;
        
    end
    
    
    
    
    
end