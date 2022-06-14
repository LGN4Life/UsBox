function [lfp, noise_trials]  = NoiseTrials(lfp,noise_threshold)
%removes noise trials from matrix of lfp data. If the lfp crosses a
%user defined noise threshold, then that trials in removed (set to nan)
%input:
%      lfp: time x trials
% (optional)
%      noise threshold: standard deviations above which is considered
%      noise. Defalut value = 6;
%
%ouput:
%      lfp data with noise trials set to nan;
%      noise_trials: logical array of noise trials (1 = noise trial);


if ~exist('noise_threshold','var')
    noise_threshold = 6;
end

noise_threshold = nanstd(lfp(:))*noise_threshold;

noise_trials=sum(abs(lfp)>noise_threshold)>1;
x = 0:length(lfp(:))/10:length(lfp(:));
% figure(1),plot(lfp(:))
% hold on
% plot(x,ones(1,length(x))*noise_threshold,'--k')
% hold off
lfp(:,noise_trials)=nan;




