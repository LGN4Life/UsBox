function [TrialParameters,CompletedTrials] = TextKeyExtract(Parameters)


Requested_StringArray = AlertTuning.WriteStringArray;

[TextID,KeyID] = AlertTuning.DetermineTextMarkerID(Parameters.ParameterChannels,Requested_StringArray);

%if the tuning curve involves the fixation point color, than the extracted
%RGB needs to be condenced to the single changing value
if strcmp(Parameters.TuningParameters.Type,'FixptColor')
    
    TextID = AlertTuning.convert_rgb(TextID);
    
    
else
    if isfield(Parameters.TuningParameters,'Type1')
        if strcmp(Parameters.TuningParameters.Type1,'FixptColor') | strcmp(Parameters.TuningParameters.Type2,'FixptColor')
            TextID = AlertTuning.convert_rgb(TextID);
            
        end
        
    end
    
    
end

if isempty(KeyID.OptoState.timestamps)
    Parameters.OptoExp=false;
end

TrialParameters = AlertTuning.KeyIDConvert(KeyID,TextID);

if ~isempty(Parameters.ParameterChannels.OptoParameters)
    TrialParameters.OptoState = AlertTuning.KeyIDConvert_Opto(KeyID);
else
    TrialParameters.OptoState=[];
    
end


CompletedTrials = AlertTuning.CalculateCompletedTimes(TrialParameters,Parameters.ParameterChannels);









