function [ wave_forms, wave_times] = GetSpikeWavemarks(fhand,spike_channel,wavemark,spike_times)


%
%load spike waveforms from smr(x) file
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

%To avoid importing more than 1 spike time at a time, only read n number of "events"
%which should be the length of 1 wavemark
max_events = 20; 

%this can't be the easiest way to do this, but the CEDMatlab toolbox
%doesn't seem to offer an alternative
%precalculate the spike times (in Spike2.LoadSpikeTimes)
%convert to ticks
%use these ticks to extract the waveforms for each spike.

[ spike_ticks ] = CEDS64SecsToTicks( fhand, spike_times );

tic

%% This section contains the three necessary operations to import spike times
%1. Set marker mask
%2. Read in waveforms using precalculted spike times


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
%option. CEDS64ReadWaveF only reads in one spike at a time, but there
%doesn't seem to be another option

wave_forms = [];

for index = 1:length( spike_ticks)
    % it seems like the number of data points in a wavemark changes
    % from file to file (sampling rate?). I can't find a way to explicitly
    % determine the length wavemarks  so I have used this hack. 
    wave_times(index,1:20) = nan;
    [ iRead, current_wave_form, current_wave_time ] = CEDS64ReadWaveF(fhand, spike_channel, max_events, spike_ticks(index),-1,mask_handle);



    wave_times(index,1) = current_wave_time;
    wave_forms(index,1:length(current_wave_form)) = current_wave_form;

end





%convert times from ticks to seconds
if ~isempty(spike_times)
    wave_times = CEDS64TicksToSecs(fhand,wave_times);
end




% %load in tamplet info and extract requested wave mark
% [ iRead , marker_obj ] = CEDS64ReadMarkers( fhand, spike_channel, max_events, 0,-1,mask_handle);




%% 




    display([num2str(length(spike_times)) ' spike times successfuly loaded'])
    
    
  read_time = toc;

    

% close current file
%CEDS64Close(fhand);


