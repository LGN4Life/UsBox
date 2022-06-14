function remove_spike_artifact_frequency(sta, params)

params.Fs = 500;

n = find(params.spike_artifact);
x = 0:1/params.Fs: (size(sta,1)-1)/params.Fs;
params.f = 1/x(end):1/x(end):.5*params.Fs;
p1 = sta(1:n(1)-1,:);
p2 = sta(n(end)+1:end,:);
ps_1 = LFP.custom_fft(p1,params.f,params.Fs);
ps_2 = LFP.custom_fft(fliplr(p2),params.f,params.Fs);
% ps_3 = fft(p1); f1 = 1/x(end); f = f1*(0:(size(ps_3,1)-1)/2);
% ps_3 = ps_3(2:end,:);
og = sta;

tic
for spike_index = 1:size(ps_1,2)
    if mod(spike_index,1000)==0
        toc
        fprintf('spike index = %d\n', spike_index)
    end
    for f_index = 1:size(ps_1,1)
        r1(f_index,:) = real(ps_1(f_index,spike_index))*cos(2*pi*x*params.f(f_index)) + ...
            imag(ps_1(f_index,spike_index))*sin(2*pi*x*params.f(f_index)) + ...
            real(conj(ps_1(f_index,spike_index)))*cos(2*pi*x*params.f(f_index)) + ...
            imag(conj(ps_1(f_index,spike_index)))*sin(2*pi*x*params.f(f_index));
        r2(f_index,:) = real(ps_2(f_index,spike_index))*cos(2*pi*x*params.f(f_index)) + ...
            imag(ps_2(f_index,spike_index))*sin(2*pi*x*params.f(f_index))  + ...
            real(conj(ps_2(f_index,spike_index)))*cos(2*pi*x*params.f(f_index)) + ...
            imag(conj(ps_2(f_index,spike_index)))*sin(2*pi*x*params.f(f_index));
    end
    %r = mean((r1+r2)/2,1);
    r= sum(r1);
    r= r-mean(r(:));
    figure(1),plot(sta(:,spike_index))
    hold on
    sta(params.spike_artifact,spike_index) = std(sta(:))*r(params.spike_artifact)/std(r(:));
    figure(1),plot(sta(:,spike_index))
    hold off

    
    figure(2),cla, plot(mean(og(:,1:spike_index),2))
    hold on
    plot(mean(sta(:,1:spike_index),2))
    hold off
    
    figure(3),plot(r)
    

    
end
figure(1),plot(mean(sta,2))
pause