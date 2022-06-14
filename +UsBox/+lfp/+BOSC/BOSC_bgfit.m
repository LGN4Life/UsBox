function [pv,meanpower]=BOSC_bgfit(F,B,freq_range)
% [pv,meanpower]=BOSC_bgfit(F,B)
%
% This function estimates the background power spectrum via a
% linear regression fit to the power spectrum in log-log coordinates
% 
% parameters:
% F - vector containing frequencies sampled
% B - matrix containing power as a function of frequency (rows) and
% time). This is the time-frequency data.
%
% returns:
% pv = contains the slope and y-intercept of regression line
% meanpower = mean power values at each frequency 
%
lim_f = F(F>=7 | F<=60);
%lim_f = F(F<4 | F ==8 | (F>30 & F<60));

if min(size(B)>1)
    B = mean(log10(B),2)';
    B = B(F>=7 | F<=60);
    %B = B(F<4 | F ==8 | (F>30 & F<60));
    pv=polyfit(log10(lim_f),B,1); % linear regression
    
else
    B = B(F>=7 | F<=60);
    %B = B(F<4 | F ==8 | (F>30 & F<60));
    pv=polyfit(log10(lim_f),log10(B),1); % linear regression
end

% transform back to natural units (power; usually uV^2/Hz)
meanpower=10.^(polyval(pv,log10(F)));     
