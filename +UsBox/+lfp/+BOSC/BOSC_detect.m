
function [detected, epi_duration, epi_bins] =BOSC_detect(b,powthresh,durthresh,Fsample)
% detected=BOSC_detect(b,powthresh,durthresh,Fsample)
%
% This function detects oscillations based on a wavelet power
% timecourse, b, a power threshold (powthresh) and duration
% threshold (durthresh) returned from BOSC_thresholds.m.
%
% It now returns the detected vector which is already episode-detected.
%
% b - the power timecourse (at one frequency of interest)
%
% durthresh - duration threshold in  required to be deemed oscillatory
% powthresh - power threshold
%
% returns:
% detected - a binary vector containing the value 1 for times at
%            which oscillations (at the frequency of interest) were
%            detected and 0 where no oscillations were detected.
%epi_duration - length of each episode (in bins);
%epi_bins - start and end bin for each episode
% 
% NOTE: Remember to account for edge effects by including
% "shoulder" data and accounting for it afterwards!
%
% To calculate Pepisode:
% Pepisode=length(find(detected))/(length(detected));                           
epi_duration = [];
epi_bins = [];
t=(1:length(b))/Fsample;
nT=length(b); % number of time points

x=b>powthresh; % Step 1: power threshold
dx=diff(x); pos=find(dx==1)+1; neg=find(dx==-1)+1; % show the +1 and -1 edges

% now do all the special cases to handle the edges
detected=zeros(size(b));
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
      epi_bins(h,:) = [H(1,h) H(2,h)];
  end
end % more than one "hole"
