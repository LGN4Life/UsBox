function Requested_ParameterChannels = InitializeExcelDataStruct



%Channel requests.  this should be made more flexible
Requested_ParameterChannels.types = [5 8 4 4 4 1 5]; % Parameter types for each file type
Requested_ParameterChannels.DataStructFields ={'KeyboardParameters' ...
    'TextParameters' 'StimulusParameters' 'FixationParameters' 'FrameParameters' 'FiberChannel' 'DigMark' 'Trigger'};
%RequestedColumns_ParameterChannels={'Keyboard' 'untitled' 'Stim' 'Fixation' 'Frame'};
Requested_ParameterChannels.string{1} = 'Keyboard';
Requested_ParameterChannels.field{1} = 'KeyboardParameters';
Requested_ParameterChannels.string{2} = 'TextChannel';
Requested_ParameterChannels.field{2} = 'TextParameters';
Requested_ParameterChannels.string{3} = 'Stim$';
Requested_ParameterChannels.field{3} = 'StimulusParameters';
Requested_ParameterChannels.string{4} = 'Fixpt$';
Requested_ParameterChannels.field{4} = 'FixationParameters';
Requested_ParameterChannels.string{5} = 'Frame$';
Requested_ParameterChannels.field{5} = 'FrameParameters';
Requested_ParameterChannels.string{6} = 'Optic';
Requested_ParameterChannels.field{6} = 'FiberChannel';
Requested_ParameterChannels.string{7} = 'DigMark';
Requested_ParameterChannels.field{7} = 'DigMark';
Requested_ParameterChannels.string{7} = 'Trigger';
Requested_ParameterChannels.field{7} = 'Trigger';


