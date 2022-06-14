function [onset_y,offset_y,x] = by_trial(eyd,Triggers,max_trial_duration)

trial_duration =  Triggers(:,2)-Triggers(:,1);

over_time = trial_duration>max_trial_duration;

Triggers(over_time,2) = Triggers(over_time,1)+max_trial_duration;


pre_window = 0;


bin_size = eyd.time(2) - eyd.time(1);
x = -pre_window:bin_size:max_trial_duration;
onset_y = nan(size(Triggers,1),length(x));
offset_y = nan(size(Triggers,1),length(x));
for trial_index = 1:size(Triggers,1)
   current_bins =  eyd.time>=Triggers(trial_index,1)-pre_window & eyd.time<=Triggers(trial_index,2);
   L = sum(current_bins);
   onset_y(trial_index,1:L) = eyd.size(current_bins);

   current_bins =  eyd.time>=Triggers(trial_index,2)-pre_window & eyd.time<=Triggers(trial_index,2)+max_trial_duration;
   L = sum(current_bins);
   offset_y(trial_index,1:L) = eyd.size(current_bins);
   

    
end
% figure(10),subplot(1,2,1),plot(x,nanmean(onset_y)), axis square
% xlabel('time (0 = stimulus onset)')
% ylabel('pupil size (a.u.)')
% 
% figure(10),subplot(1,2,2),plot(x,nanmean(offset_y)), axis square
% xlabel('time (0 = stimulus offset)')
% ylabel('pupil size (a.u.)')
