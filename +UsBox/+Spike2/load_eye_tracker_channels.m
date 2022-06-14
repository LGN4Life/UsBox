function eye_pos = load_eye_tracker_channels(data,ds_factor)

         
fhand = UsBox.Spike2.OpenSmrFile([data.Parameters.FileNames.Spike2 '.smr']);

[channel_info] = UsBox.Spike2.GetChannelLabels(fhand);

chan_num(1)=channel_info.number(strcmp(channel_info.names,'Eye X'));
x= ContinuousRecording;
[x,read_time] = UsBox.AlertTuning.LoadContinuous(fhand,chan_num(1),x);

chan_num(2)=channel_info.number(strcmp(channel_info.names,'Eye Y'));
y= ContinuousRecording;
[y,read_time] = UsBox.AlertTuning.LoadContinuous(fhand,chan_num(2),y);
if ~isfield(data.Parameters,'GeneralInformation')
    data.Parameters.GeneralInformation.EyeCoilSoftwareGainX = '2.3';
    data.Parameters.FixationPoint.PositionXDegrees='0';
    data.Parameters.GeneralInformation.EyeCoilSoftwareGainY = '2.3';
    data.Parameters.FixationPoint.PositionYDegrees='0';
end


eye_pos.x = x.Y*str2num(data.Parameters.GeneralInformation.EyeCoilSoftwareGainX);
eye_pos.y = y.Y*str2num(data.Parameters.GeneralInformation.EyeCoilSoftwareGainY);
if isfield(data.Parameters,'FixationPoint')
    eye_pos.x = eye_pos.x - str2num(data.Parameters.FixationPoint.PositionXDegrees);
    eye_pos.y = eye_pos.y - str2num(data.Parameters.FixationPoint.PositionYDegrees);
else
    eye_pos.x = eye_pos.x - str2num(data.Parameters.ExperimentalParameters.FixationX);
    eye_pos.y = eye_pos.y - str2num(data.Parameters.ExperimentalParameters.FixationY);
    
end



% 



eye_pos.t = x.X;
if ds_factor>1
    eye_pos.x = downsample(eye_pos.x,ds_factor);
    eye_pos.y = downsample(eye_pos.y,ds_factor);
end



CEDS64Close(fhand);