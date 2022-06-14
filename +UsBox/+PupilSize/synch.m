function eyd = synch(eyd,smr)


smr.markers = cell2mat(smr.markers);
%remove extra 101s from front of smr data
temp_remove = find(smr.markers~=101);
temp_remove = temp_remove(1);
smr.markers =smr.markers([1 temp_remove:end]);
smr.timestamps =smr.timestamps([1 temp_remove:end]);
eyd.data.time = nan(length(eyd.data.xdat),1);


trans_vector_full = cat(1, double(eyd.data.xdat(1:end-1)) - double(eyd.data.xdat(2:end)),0);

trans_vector = find(trans_vector_full ~=0);


for index = 1:length(trans_vector)
   
     trans_tracker(index,:) = [double(smr.markers(index)) double(eyd.data.xdat(trans_vector(index))) double(trans_vector(index))];
%      figure(1),plot(eyd.data.xdat(1:trans_vector(index)+1))
%      figure(2),plot(trans_vector_full(1:trans_vector(index)))
%     trans_tracker(index,:) 
    
    if index == 1
        eyd.data.time(1:trans_vector(index)) = (-trans_vector(index):-1)*(1/eyd.rate)+smr.timestamps(index);
        eyd.data.time(trans_vector(index)+1) = smr.timestamps(index);
        s = length(eyd.data.time(trans_vector(index)+2:end));
        eyd.data.time(trans_vector(index)+2:end) = (1:s)*(1/eyd.rate)+smr.timestamps(index);
    else
%         
%         s = length(trans_vector(index-1)+2:trans_vector(index));
%         eyd.data.time(trans_vector(index-1)+2:trans_vector(index)) =  (1:s)*(1/eyd.rate) + smr.timestamps(index-1);
    end
     sync_check(index,:) = [smr.timestamps(index)  eyd.data.time(trans_vector(index)+1) smr.timestamps(index)- eyd.data.time(trans_vector(index)+1)];
%     trans_tracker(index,:) 
% 


end










