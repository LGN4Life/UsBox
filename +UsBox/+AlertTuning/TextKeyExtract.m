function [TrialParameters,CompletedTrials] = TextKeyExtract(Parameters)








Requested_StringArray = UsBox.AlertTuning.WriteStringArray;

[TextID,KeyID] = UsBox.AlertTuning.DetermineTextMarkerID(Parameters.ParameterChannels,Requested_StringArray);

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

TrialParameters = UsBox.AlertTuning.KeyIDConvert(KeyID,TextID);

if ~isempty(Parameters.ParameterChannels.OptoParameters)
    TrialParameters.OptoState = AlertTuning.KeyIDConvert_Opto(KeyID);
else
    TrialParameters.OptoState=[];
    
end


CompletedTrials = UsBox.AlertTuning.CalculateCompletedTimes(TrialParameters,Parameters.ParameterChannels);




if ~isempty(CompletedTrials.Stimulus)
    
    
    if isfield(Parameters.ExcelData,'TimeRange')
        
        TimeRange=eval(Parameters.ExcelData.TimeRange);
        
        CompletedTrials.TimeRange = CompletedTrials.Stimulus(:,2)>=TimeRange(1)...
            & CompletedTrials.Stimulus(:,2)<=TimeRange(2);
        
    else
        CompletedTrials.TimeRange = logical(ones(size(CompletedTrials.Stimulus,1),1));
        
    end
    TrialThreshold=1;
    if ~isempty(Parameters.ParameterChannels.OptoParameters)
        [TrialParameters,CompletedTrials] = UsBox.AlertTuning.CalculateOptoTriggerTimes(Parameters.ParameterChannels,CompletedTrials,TrialParameters);
        CompletedTrials.BlockTrial = AlertTuning.DivideTrialBlocks(CompletedTrials.OptoState,TrialThreshold);
    else
        CompletedTrials.OptoState = zeros(size(CompletedTrials.TimeRange,1),2);
        CompletedTrials.OptoTriggers = zeros(size(CompletedTrials.TimeRange,1),2);
    end
    
end






