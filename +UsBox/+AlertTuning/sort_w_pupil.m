function data = sort_w_pupil(data,pupil,TrialIV,pupil_logical)
if isempty(pupil_logical)
    pupil_logical =  true(length(data.TrialF1),1);
end
unique_IV = unique(TrialIV);
data.TrialMean_Z = nan(1,length(data.TrialMean));
data.TrialF1_Z = nan(1,length(data.TrialF1));
data.TrialPupil = nan(1,length(data.TrialF1));
data.TrialPupil_Z = nan(1,length(data.TrialF1));

for index = 1:length(unique_IV)

    current_trials =  TrialIV==unique_IV(index) & pupil_logical;
  
    data.F1(index) =  nanmean(data.TrialF1(current_trials));
    data.TrialF1_Z(current_trials) = (data.TrialF1(current_trials) - nanmean(data.TrialF1(current_trials)))/std(data.TrialF1(current_trials));
    data.F1_e(index) =  nanstd(data.TrialF1(current_trials))/sqrt(sum(current_trials));
    data.Mean(index) =  nanmean(data.TrialMean(current_trials));
    data.TrialMean_Z(current_trials) = (data.TrialMean(current_trials) - nanmean(data.TrialMean(current_trials)))/std(data.TrialMean(current_trials));
    data.Mean_e(index) =  nanstd(data.TrialMean(current_trials))/sqrt(sum(current_trials));
    current_pupil = pupil.onset_y(current_trials,:);
    data.Pupil(index) =  nanmean(current_pupil(:));
    data.TrialPupil(current_trials) = nanmean(current_pupil,2);
    data.TrialPupil_Z(current_trials) = (data.TrialPupil(current_trials) - nanmean(data.TrialPupil(current_trials)))/std(data.TrialPupil(current_trials));
    

    data.PSTH(index,:) =  nanmean(data.TrialPSTH(current_trials,:),1);
    data.PSTH_e(index,:) =  nanstd(data.TrialPSTH(current_trials,:),[],1)/sqrt(sum(current_trials));
    if size(data.TrialCycleHist,2)>1
        data.CycleHist(index,:) =  nanmean(data.TrialCycleHist(current_trials,:),1);
    else
        data.CycleHist(index) = nan;
    end
end

data.TrialIV = TrialIV;
data.IV = unique_IV;