function data = sort(data,TrialIV,smooth_flag, iv_list)

if ~exist('iv_list','var')
    unique_IV = unique(TrialIV);
    unique_IV = unique_IV(isfinite(unique_IV));
else
    unique_IV = iv_list;
end
if nargin==2
    smooth_flag = false;
elseif smooth_flag
    gauss_x =-5:5;
    gauss_filter = normpdf(gauss_x,0, 1);
    
end
for index = 1:length(unique_IV)
    current_trials =  TrialIV==unique_IV(index);
    data.F1(index) =  nanmean(data.TrialF1(current_trials));
    data.F1_e(index) =  nanstd(data.TrialF1(current_trials))/sqrt(sum(current_trials));
    
    data.F2(index) =  nanmean(data.TrialF2(current_trials));
    data.F2_e(index) =  nanstd(data.TrialF2(current_trials))/sqrt(sum(current_trials));
    
    data.Mean(index) =  nanmean(data.TrialMean(current_trials));
    data.Mean_e(index) =  nanstd(data.TrialMean(current_trials))/sqrt(sum(current_trials));
    
    data.PSTHMean(index) =  nanmean(data.TrialPSTHMean(current_trials));
    data.PSTHMean_e(index) =  nanstd(data.TrialPSTHMean(current_trials))/sqrt(sum(current_trials));
    
    if smooth_flag
        data.PSTH(index,:) =  conv(nanmean(data.TrialPSTH(current_trials,:),1),gauss_filter,'same');
    else
        data.PSTH(index,:) =  nanmean(data.TrialPSTH(current_trials,:),1);
    end
    
    data.PSTH_e(index,:) =  nanstd(data.TrialPSTH(current_trials,:),[],1)/sqrt(sum(current_trials));
    if size(data.TrialCycleHist,2)>1
        data.CycleHist(index,:) =  nanmean(data.TrialCycleHist(current_trials,:),1);
    else
        data.CycleHist(index) = nan;
    end
end

data.TrialIV = TrialIV;
data.IV = unique_IV;