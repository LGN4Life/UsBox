function [cycle_hist,cycle_x,cycle_hist_bs]=SingleTrialCycleHist(TrialSpikeTimes,TrialDuration,TF,bin_number)



    cycle_x = 0:(1/TF)/bin_number:1/TF;
    %cycle_x = cycle_x(1:end-1);
    cycle_hist_bs =(1/TF)/bin_number;






%adjust trial duration to be a mutiple of the stimulus cycle
   % format short
    %TF = round(TF*1000)/1000;
    CycleNum=(TrialDuration/(1/TF));
    if mod(TrialDuration,(1/TF))< (1/TF)*.99
        CycleNum=floor(CycleNum);
    else
        CycleNum=round(CycleNum);
    end
    TrialDuration=CycleNum*(1/TF);



%exclude spikes before stim onset over after stim offset

TrialSpikeTimes = TrialSpikeTimes(TrialSpikeTimes>0 & TrialSpikeTimes<=TrialDuration);

TrialSpikeTimes_mod = mod(TrialSpikeTimes,1/TF);
if isempty(TrialSpikeTimes_mod)
    TrialSpikeTimes_mod=-999;
    
end








cycle_hist =histcounts(TrialSpikeTimes_mod,cycle_x)/(cycle_hist_bs*CycleNum);




%cycle_hist = cycle_hist(1:end-1);


