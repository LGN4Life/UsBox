function continuous_recording = filter_cheby2(continuous_recording,FreqRange)

% if length(varargin)==1
%     filter_option =varargin{1};
%     
% else
%     filter_option = 'low';
%     fprintf('no filter type specified, low pass filtering at %dHz\n',FreqRange(2)); 
% end
F_Deg = 10;



fc =249;
fs = continuous_recording.Fs;

[b,a] = cheby2(F_Deg,50,fc/(fs/2));



% figure(1)
% freqz(b,a,[],continuous_recording.Fs)
% figure(1),subplot(2,1,1),set(gca,'XLim',[0 200]),set(gca,'YLim',[-10 0])
% figure(1),subplot(2,1,2),set(gca,'XLim',[0 200])
% pause(.1)


continuous_recording.Y = filtfilt(b,a,continuous_recording.Y);

continuous_recording.filter = FreqRange;













