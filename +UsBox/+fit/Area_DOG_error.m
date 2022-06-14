function [err] = Area_DOG_error(param, x, RESP)


[res] 	= Area_DOG(x,param);
[val,id]=max(RESP);

w		= 1;
if size(res,1)==size(RESP,1)
    RESP = w*RESP;
else
    RESP = w*RESP';
end


res=res*w;


err 	= (sum((1.*(res-RESP)).^2));

% figure(5),plot(RESP,'o')
% hold on
% plot(res)
% hold off
% pause
