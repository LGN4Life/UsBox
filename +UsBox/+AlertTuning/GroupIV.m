function IV = GroupIV(IV,new_iv)

[~,~,bins]=histcounts(IV,new_iv);
IV=new_iv(bins);
% IV(IV>100)=100;



