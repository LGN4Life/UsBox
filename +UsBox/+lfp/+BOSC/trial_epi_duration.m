function [detected, epi_duration] = trial_epi_duration(x,durthresh)

%episodes are detected in full lfp vector (trials and intratrials)
%use this function to determine the duration of each episode that occurs
%during a trail
%input:
%   x - logical matrix (trials, time). true  = episode detected, false  =
%   not detected. 
epi_duration =[];
nT=length(x); % number of time points
dx=diff(x); pos=find(dx==1)+1; neg=find(dx==-1)+1; % show the +1 and -1 edges

% now do all the special cases to handle the edges
detected=zeros(size(x));
if(isempty(pos) & isempty(neg))
  if(find(x)>0) H=[1;nT]; else H=[]; end % all episode or none
elseif(isempty(pos)) H=[1;neg]; % i.e., starts on an episode, then stops
elseif(isempty(neg)) H=[pos;nT]; % starts, then ends on an ep.
else
  if(pos(1)>neg(1)) pos=[1 pos]; end; % we start with an episode
  if(neg(end)<pos(end)) neg=[neg nT]; end; % we end with an episode
  H=[pos;neg]; % NOTE: by this time, length(pos)==length(neg), necessarily
end; % special-casing, making the H double-vector

if(~isempty(H)) % more than one "hole"
                % find epochs lasting longer than minNcycles*period
  goodep=find((H(2,:)-H(1,:))>=durthresh);
  if(isempty(goodep)) H=[]; else H=H(:,goodep); end;
  % OR this onto the detected vector
  for h=1:size(H,2) 
      detected(H(1,h):H(2,h))=1;
      epi_duration(h) = length(H(1,h):H(2,h));
  end
end % more than one "hole"