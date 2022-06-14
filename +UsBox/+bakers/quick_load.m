function [CompletedTrials,AllTrials,Parameters] = quick_load(file_name)


if ~libisloaded('ceds64int')
    cedpath = 'C:\CEDMATLAB\CEDS64ML\'; % if no environment variable (NOT recommended)
    CEDS64LoadLib( cedpath ); % load ceds64int.dll
end
par_file = [file_name '.par'];
smr_file = [file_name '.smrx'];

%load parameters from par file 
Parameters = UsBox.Spike2.LoadParFileInfo(par_file);

% contruct stimulus list
stim_list = UsBox.bakers.get_stim_list(Parameters.TuningParameters.ValuesAre);

%open smr file
fhand = UsBox.Spike2.OpenSmrFile(smr_file);

%get channel labels
[channel_info] = UsBox.Spike2.GetChannelLabels(fhand);

%load text channel

text_channel_number = channel_info.number(strcmp(channel_info.names,'TextMark'));
Parameters.ParameterChannels.TextParameters = UsBox.Spike2.LoadTextChannel(fhand,text_channel_number);


%load keyboard channel
keyboard_channel_number = channel_info.number(strcmp(channel_info.names,'Keyboard'));
Parameters.ParameterChannels.KeyboardParameters= UsBox.Spike2.LoadKeyboardChannel(fhand,keyboard_channel_number);


%load fixation times
fixation_channel_number = channel_info.number(strcmp(channel_info.names,'Fixpt'));
Parameters.ParameterChannels.FixationParameters.timestamps  = UsBox.AlertTuning.LoadLevelTimeStamps(fixation_channel_number,fhand);



%load stim times
stim_channel_number = channel_info.number(strcmp(channel_info.names,'Stim'));
Parameters.ParameterChannels.StimulusParameters.timestamps  = UsBox.Spike2.LoadLevelTimeStamps(stim_channel_number,fhand);

%load intan
intan_channel_number = channel_info.number(strcmp(channel_info.names,'INTAN-T'));
Parameters.ParameterChannels.IntanParameters.timestamps  = UsBox.Spike2.LoadLevelTimeStamps(intan_channel_number,fhand);

Parameters.ParameterChannels.OptoParameters= [];
[AllTrials,CompletedTrials] = UsBox.bakers.TextKeyExtract(Parameters);

CompletedTrials.stim_list = stim_list;

AllTrials.stim_list = stim_list;


CEDS64Close(fhand);
