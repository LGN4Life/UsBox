function [TrialMean,TrialF1,TrialF2,TrialPhase]=SingleTrialFiringRate(cycle_hist,TF)


if ~exist('TF','var')
    TF=0;
end

if TF>.1

  
    amp_spect=fft(cycle_hist)/(length(cycle_hist));
    
    TrialMean=amp_spect(1);
    TrialF1=2*(abs(amp_spect(2)));
    TrialF2=2*(abs(amp_spect(3)));
    TrialPhase = angle(amp_spect(2));

    
else
    TrialMean = nanmean(cycle_hist);
    TrialF1=nanmean(cycle_hist);
    TrialF2=nanmean(cycle_hist);
    TrialPhase = nan;
end







%  Trial_F1
% figure(100),plot(trial_hist)
% pause
%pause