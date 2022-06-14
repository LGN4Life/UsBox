function continuous_recording = subsample(continuous_recording, target_frequency)

if continuous_recording.Fs<20000
    R =ceil(continuous_recording.Fs/target_frequency);
else
    R =floor(continuous_recording.Fs/target_frequency);
end
 %the length of recording may not be divisable by the new subsample factor
 %remove access sample from the end
 new_length =floor(length(continuous_recording.Y)/R)*R;
 new_sample_number=floor(length(continuous_recording.Y)/R);
 continuous_recording.Y=continuous_recording.Y(1:new_length);
 continuous_recording.Y=reshape(continuous_recording.Y,R,new_sample_number);
 continuous_recording.Y=mean(continuous_recording.Y);
continuous_recording.interval = continuous_recording.interval*R;
continuous_recording.Fs=1/continuous_recording.interval;
continuous_recording.length = length(continuous_recording.Y);
continuous_recording.X = continuous_recording.interval:continuous_recording.interval:...
    continuous_recording.interval*(continuous_recording.length);


new_x = continuous_recording.X(1):1/target_frequency:max(continuous_recording.X);
continuous_recording.Y = interp1(continuous_recording.X,continuous_recording.Y,new_x);
continuous_recording.X=new_x;
continuous_recording.interval = 1/target_frequency;
continuous_recording.Fs=1/continuous_recording.interval;
continuous_recording.length = length(continuous_recording.Y);



