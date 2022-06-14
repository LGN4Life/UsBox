function OrgPhase = GetPhaseFromHeader(markers);
%Use this function to calculate initial stimulus phase from old files that
%had error in par file

for index=1:size(markers,1)
    
    current_string = char(markers(:,index))';
   
    [names,extents] =regexp(current_string,'(?<org_phase>\d*,{0}\.{0,1}\d+),b,s,e','names','tokenextents');
    if ~isempty(extents)
        OrgPhase =str2num(names.org_phase);
    %    current_string
        break
    end

    
    
end
% OrgPhase
if length(OrgPhase)>1
    names
        extents
   OrgPhase
   pause
end
