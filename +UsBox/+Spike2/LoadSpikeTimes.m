function [spike_times,read_time] = LoadSpikeTimes(fhand,spike_channel,wavemark)
%
%load spike times from smr(x) file
%
%input:
%
%file_name  = smr(x) file


%check to see if the CED library has been loaded. It seems this needs to be
%reloaded everytime you start matlab, but perhaps there is a way to make it
%load automatically at startup
if ~libisloaded('ceds64int')
    cedpath = 'C:\CEDMATLAB\CEDS64ML\'; % if no environment variable (NOT recommended)
    CEDS64LoadLib( cedpath ); % load ceds64int.dll
end

%annoyingly, the CED library requires an imput that sets a limit to the
%number of spike times to load. If you set an unreasonably large value, it
%grind the system to a halt
%Use a relatively small value, then loop and concatenate
max_events = 1000; 



tic

%% This section contains the three necessary operations to import spike times
%1. Set marker mask
%2. Read in spikes
%3. convert times from 1401 ticks to seconds



%set marker mask to only import requested wavemark


mask_handle = 1;

CEDS64MaskMode(mask_handle, 0); % set to AND mode
mask = ones(256, 4, 'uint8'); % 256x4 matrix of 8-bit integers set to zero


%mask(wavemark+1, 1) = 1; % this includes code 1 in first layer
mask([1:wavemark wavemark+2:end], 1) = 0; 
%        % Library calls by function
%mask(1:end, 2:4) = 1; % include all codes in remaining layers
CEDS64MaskCodes(mask_handle, mask); % copy the codes to the mask

%Load spike times from .smr(x) file.  Currently, this seems to be the best
%option. In theory,  CEDS64ReadWaveF should also work, but it seems to load
%in a single spike at a time? Use CEDS64ReadWaveF for waveform data and to
%get spike waveforms

start_tick = 0;
spike_times = [];
exit_flag= false;
while ~exit_flag
    [ iRead, current_spike_times ] = CEDS64ReadEvents( fhand, spike_channel, max_events, start_tick,-1,mask_handle);
    %[ iRead, current_efference] = CEDS64ReadWaveF( fhand, data.Parameters.ExcelData.EfferenceCopy, max_data_points,start_tick);
    spike_times = cat(1,spike_times,current_spike_times);
    if length(current_spike_times) ~=  max_events;
        
        exit_flag = true;
    else
        start_tick = current_spike_times(end)+1;
    end
end




%convert times from ticks to seconds
if ~isempty(spike_times)
    spike_times = CEDS64TicksToSecs(fhand,spike_times);
end




% %load in tamplet info and extract requested wave mark
% [ iRead , marker_obj ] = CEDS64ReadMarkers( fhand, spike_channel, max_events, 0,-1,mask_handle);




%% 




    display([num2str(length(spike_times)) ' spike times successfuly loaded'])
    
    
  read_time = toc;

    

% close current file
%CEDS64Close(fhand);


