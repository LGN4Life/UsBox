function TF = DetermineTemporalFrequency(data)
if isfield(data.Parameters.TuningParameters,'Type')
    if strcmp(data.Parameters.TuningParameters.Type,'Temporal Frequency')
        TF = data.Parameters.CompletedTrials.IV;
    else
        TF = ones(length(data.Parameters.CompletedTrials.IV),1)*str2num(data.Parameters.Stimulus.TemporalFrequency);
        
    end
    
else
    if ~isfield(data.Parameters.Stimulus,'TF')
        data.Parameters.Stimulus.TF=0;
    end
    TF = ones(length(data.Parameters.CompletedTrials.IV),1)*str2num(data.Parameters.Stimulus.TF);
  %temp hack for star stim
    %data.SpikeData.TF = ones(size(data.Parameters.CompletedTrials.IV(:,1),1),1)*0;
    %data.Parameters.StimulusParameters.TF=0;
    
end



