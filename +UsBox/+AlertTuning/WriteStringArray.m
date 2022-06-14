function Requested_StringArray = WriteStringArray


%determine basic trial sequence from keyboard channel
%there are seveal basic forms of a trial
% "fixation on(F),  clear screan (X)" Fixation never acquired
% "fixation on(F),  stimulus on (S), stimulus off (s), clear screan (X)"
%       stimulus was turned on, trial completion uncertain
%(s) does not appear if fixation was never broken during stim presentation

Requested_StringArray.key_string{1} = '(?<FixOn>F)'; Requested_StringArray.key_field{1} = 'FixationOn'; 
%Requested_StringArray.key_string{2} = '(?<StimOn>S)(?<Reward>R){0,1}(?<StimOff>s|X)'; Requested_StringArray.key_field{2} = 'StimTrial';
%Requested_StringArray.key_string{2} = '(?<StimOn>S)O{0,1}o{0,1}f{0,1}R{0,1}(?<StimOff>s|X)'; Requested_StringArray.key_field{2} = 'StimTrial';
Requested_StringArray.key_string{2} = '(?<StimOn>S)[^SFa]*(?<StimOff>X|s)'; Requested_StringArray.key_field{2} = 'StimTrial';
%serach for opto parameters
Requested_StringArray.key_string{3} ='(?<opto_state>N{0,1})|(?<opto_state>O{0,1})';Requested_StringArray.key_field{3} = 'OptoState'; %indicates if current trial is opto_on or opto_off

Requested_StringArray.key_string{4} ='(?<reward>R)';Requested_StringArray.key_field{4} = 'Reward'; %indicates if current trial is opto_on or opto_off



%search for stim on text marker
%this was recently changed to accomodate RGB values for the fixation point
%210621, hja
%Requested_StringArray.string{1} ='T,(?<IV>-*\d*\.*\d*)'; %old string
%simply looking for a floating point number

Requested_StringArray.string{1} ='T,(*(?<IV>\d*/\d*/\d*)|T,(?<IV>-*\d+\.*\d*)'; %new string to allow for RGB
%first looks for RGB (e.g., T,(255/255/255)) and then normal IV value (e.g.,T,8.54)
Requested_StringArray.field{1} = 'StimOn';



%serach for trial advance
Requested_StringArray.string{2} ='(?<!\W|\w)(?<trial_advance>+\S{0})|(?<!\W|\w)(?<trial_advance>-\S{0})'; %(?<!\W|\w) means that the expression is preceded by any characters
Requested_StringArray.field{2} = 'TrialAdvance';

Requested_StringArray.string{3} ='T2,(?<IV>-*\d*\.*\d*)';
Requested_StringArray.field{3} = 'SecondIV_Value';






% F = Fixation on; X = Clear screan; S = Stim on; s = Stim off
%a = advance to text trial; R = reward
%find subset of fixation trials where the stimulus came on.  Need count to
%determine the  aboorted trial rate

% find subset of trials where stimulus changed

% determine behavioral response

%determine attention condition and trial type
