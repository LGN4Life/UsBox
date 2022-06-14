function [continuous_recording,read_time] = LoadContinuous(fhand,data_channel,varargin)

if isempty(varargin)
    continuous_recording = ContinuousRecording;
else
    continuous_recording = varargin{1};
end
%
%load continuous recordings from smr(x) file
%
%input:
%
%file_name  = smr(x) file
%
% data_channel = the channel within the smr(x) to load into matlab.


%check to see if the CED library has been loaded. It seems this needs to be
%reloaded everytime you start matlab, but perhaps there is a way to make it
%load automatically at startup
if ~libisloaded('ceds64int')
    cedpath = 'C:\CEDMATLAB\CEDS64ML\'; % if no environment variable (NOT recommended)
    CEDS64LoadLib( cedpath ); % load ceds64int.dll
end
tic

continuous_recording.Fs = 1.0/(CEDS64ChanDiv(fhand, data_channel)*CEDS64TimeBase(fhand));

% get waveform data from channel 1
maxTimeTicks = CEDS64ChanMaxTime( fhand, data_channel )+1; % +1 so the read gets the last point 



[ticks_read, continuous_recording.Y] = CEDS64ReadWaveF( fhand, data_channel, maxTimeTicks, 0, maxTimeTicks );
continuous_recording.X = (1:length(continuous_recording.Y))/continuous_recording.Fs;
continuous_recording.length = length(continuous_recording.X);
continuous_recording.interval = 1/continuous_recording.Fs;
continuous_recording.duration = max(continuous_recording.X);
display([num2str(max(continuous_recording.X)) ' sec of continuous data successfuly loaded'])

read_time = toc;







