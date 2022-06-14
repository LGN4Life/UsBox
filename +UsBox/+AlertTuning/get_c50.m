function [New_Y, New_X,Param] = get_c50(firing_rate,contrast)

options=optimset('TolFun',.0000001,'TolX',.0000001,'Display','off','MaxFunEvals',10000,'MaxIter',10000);
if nargin==2
    ic=[max(firing_rate)    ,1 , 50, 0];
    lb=[max(firing_rate)*.7 ,.1,  1, 0];
    ub=[max(firing_rate)*2  ,10,130, min(firing_rate)*1.2];
end
[Param,Flag,OutPutStruct]= fmincon('HRat_error', ic,[],[],[],[], lb,ub, [],options, contrast, firing_rate);

 New_X=linspace(min(contrast),max(contrast),200);
[New_Y]=HRat(New_X,Param);