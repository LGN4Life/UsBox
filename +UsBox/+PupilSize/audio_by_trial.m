function [onset_y,x] = audio_by_trial(eyd,StimCode)

m = 1.0; % trial duration
pre_window = 0;
eyd.pupil(eyd.status ==0) = nan;
max_trial_duration =  m;
bin_size = eyd.time(2) - eyd.time(1);
x = -pre_window:bin_size:max_trial_duration;
onset_y = nan(size(StimCode.time,1),length(x));
offset_y = nan(size(StimCode.time,1),length(x));
for trial_index = 1:length(StimCode.IV)
   current_bins =  eyd.time>=StimCode.time(trial_index)-pre_window & eyd.time<=StimCode.time(trial_index)+max_trial_duration;
   L = sum(current_bins);
   onset_y(trial_index,1:L) = eyd.pupil(current_bins);

   

   
    
    
end

