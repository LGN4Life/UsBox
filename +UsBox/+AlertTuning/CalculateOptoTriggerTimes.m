function [TrialParameters,CompletedTrials] = CalculateOptoTriggerTimes(ParameterChannels,CompletedTrials,TrialParameters);


%^calculate opto triggers from text markers
a=char(ParameterChannels.TextParameters.markers);
a=mat2cell(char(a),ones(1,size(a,1)),size(a,2));
opto_on = regexp(a,'OptoOn');
opto_on=~cellfun(@isempty,opto_on);
opto_off = regexp(a,'OptoOff');
opto_off=~cellfun(@isempty,opto_off);
ParameterChannels.FiberChannel.OptoOnset = ParameterChannels.TextParameters.timestamps(opto_on);
ParameterChannels.FiberChannel.OptoOnset=ParameterChannels.FiberChannel.OptoOnset(ParameterChannels.FiberChannel.OptoOnset>1);

ParameterChannels.FiberChannel.OptoOffset = ParameterChannels.TextParameters.timestamps(opto_off);
ParameterChannels.FiberChannel.OptoOffset=ParameterChannels.FiberChannel.OptoOffset(ParameterChannels.FiberChannel.OptoOffset>1);
%   pause

%determine exact times when laser was turned on and off
if isfield(ParameterChannels.FiberChannel,'value')
    ParameterChannels.FiberChannel.value=ParameterChannels.FiberChannel.value/max(ParameterChannels.FiberChannel.value);
    FiberDerivative = ParameterChannels.FiberChannel.value(2:end)-ParameterChannels.FiberChannel.value(1:end-1);
    
    OptoOnsetLogical = find(FiberDerivative>0.25);
    OptoOffsetLogical = find(FiberDerivative<-0.25);
    
    TrialParameters.OptoOnset=(OptoOnsetLogical-1)*(1/ParameterChannels.FiberChannel.sampling_rate);% subtract 1 because first bin ==0
    TrialParameters.OptoOffset=(OptoOffsetLogical-1)*(1/ParameterChannels.FiberChannel.sampling_rate);
else
    TrialParameters.OptoOnset=ParameterChannels.FiberChannel.OptoOnset;
    TrialParameters.OptoOffset=ParameterChannels.FiberChannel.OptoOffset;
end

CompletedTrials.OptoState(1:size(CompletedTrials.IV,1),1:2)=nan;

% temp_string =  data.Parameters.OptogeneticsParameters.PreStimulusOptoOnPostStimulusOptoOnKeepOptoOnBetweenStims;
% temp_marker = strfind(temp_string,',');
% non_opto_adjustment(1) =  str2num(temp_string(1:temp_marker(1)-1));
% non_opto_adjustment(2) =  str2num(temp_string(temp_marker(1)+1:temp_marker(2)-1));
non_opto_adjustment(1) = .5;
non_opto_adjustment(2) = 0;
for iv_index=1:size(CompletedTrials.IV,1)
    
    %find opto state
    [val,id] =min(abs(TrialParameters.OptoState(:,1)-CompletedTrials.Stimulus(iv_index,1)));

    CompletedTrials.OptoState(iv_index,:)=TrialParameters.OptoState(id,:);
    
    
    Z = TrialParameters.OptoOffset>CompletedTrials.Stimulus(iv_index,1);
    
    % %sometimes the previous opto offset is closer to
    CurrentOptoOff = TrialParameters.OptoOffset(Z);
    if CompletedTrials.OptoState(iv_index,2)==1
        [val,id_on] =min(abs(TrialParameters.OptoOnset-CompletedTrials.Stimulus(iv_index,1)));
        [val,id_off] =min(abs(CurrentOptoOff-CompletedTrials.Stimulus(iv_index,2)));
        CompletedTrials.OptoTriggers(iv_index,:)=[TrialParameters.OptoOnset(id_on) CurrentOptoOff(id_off)];
    else
        CompletedTrials.OptoTriggers(iv_index,1)=CompletedTrials.Stimulus(iv_index,1) - non_opto_adjustment(1) - rand*.025;
        CompletedTrials.OptoTriggers(iv_index,2)=CompletedTrials.Stimulus(iv_index,2) + non_opto_adjustment(2) + rand*.025;
    end
    
    

    
end











