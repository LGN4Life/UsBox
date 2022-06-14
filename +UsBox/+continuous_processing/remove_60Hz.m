function continuous_recording = remove_60Hz(continuous_recording)
% figure(1),plot(signal(1,:),'b')
% hold on

%the total length of the recording has to be a mutiple of the window size
%make this the case
window_size = 0.6;
recording_segments =floor(continuous_recording.duration/window_size);

segement_length =floor(length(continuous_recording.Y)/recording_segments);
end_segment = recording_segments*segement_length;
signal = continuous_recording.Y(1:end_segment);
signal = reshape(signal,segement_length,recording_segments)';


time = (0:segement_length-1)*1/continuous_recording.Fs;




for f_index =1:4
    CosF = cos(time*2*pi*60*f_index)';
    SinF = sin(time*2*pi*60*f_index)';
    LineNoise_Measured =(signal*CosF +i*signal*SinF)/(size(signal,2)/2);
    LineNoise_Measured = repmat(LineNoise_Measured,1,size(signal,2));
    LineNoise =time*2*pi*60*f_index;
    LineNoise =repmat(LineNoise,size(signal,1),1);
    LineNoise=imag(LineNoise_Measured).*sin(LineNoise)+real(LineNoise_Measured).*cos(LineNoise);
    signal= signal-(LineNoise);
end




continuous_recording.Y(1:end_segment) = reshape(signal',1,end_segment);
continuous_recording.Y(end_segment+1:end) = 0;
