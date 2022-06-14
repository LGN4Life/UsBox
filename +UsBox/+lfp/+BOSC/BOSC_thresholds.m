

function [powthresh,durthresh]=BOSC_thresholds(Fsample,percentilethresh,numcyclesthresh,F,meanpower)
% 
% This function calculates all the power thresholds and duration
% thresholds for use with BOSC_detect.m to detect oscillatory episodes
% Fsample - sampling rate (Hz)
% percentilethresh - power threshold expressed as a percentile/100
%                    (i.e., from 0-1) of the estimated
%                    chi-square(2) probability distribution of
%                    power values. A typical value is 0.95
% numcyclesthresh - duration threshold. A typical value is 3 cycles.
% 
% returns:
% power thresholds and duration thresholds
%
% Fsample = is the sampling rate
%
% F - frequencies sampled in the power spectrum
%
% meanpower - power spectrum (mean power at each frequency)


% power threshold is based on a chi-square distribution with df=2
% and mean as estimated previously (BOSC_bgfit.m)
powthresh=chi2inv(percentilethresh,2)*meanpower/2;
% chi2inv.m is part of the statistics toolbox of Matlab and Octave

% duration threshold is simply a certain number of cycles, so it
% scales with frequency
durthresh=(numcyclesthresh*Fsample./F)';
