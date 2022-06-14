function [noncycle_hist,noncycle_hist_x] =SingleTrialNonCycleHist(PSTH,PSTH_X,TrialDuration)

noncycle_hist=nan(1,length(PSTH_X));
current_bins = PSTH_X>0 & PSTH_X<=TrialDuration;
current_psth = PSTH(current_bins);
%current_psth=conv(current_psth,gauss_filter,'same');
        
noncycle_hist(current_bins) = current_psth;
noncycle_hist_x = PSTH_X(current_bins);




