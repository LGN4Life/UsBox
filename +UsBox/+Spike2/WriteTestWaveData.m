function write_result = WriteTestWaveData(file_name,channel_number)



%load data struct
% load('C:\Henry\CurrentAwakeData\LGNLFP\Workspaces\DataStruct\test_test_001_1_1.mat')
% [TrialParameters,CompletedTrials] = Attention_v8.TextKeyExtract(data);

load('C:\Henry\CurrentAwakeData\LGNLFP\Workspaces\DataStruct\crn_150522_test_000_196_1.mat','data')

[TrialParameters,CompletedTrials] = TuningData.Alert.TextKeyExtract(data);


if ~libisloaded('ceds64int')
    cedpath = 'C:\CEDMATLAB\CEDS64ML\'; % if no environment variable (NOT recommended)
    CEDS64LoadLib( cedpath ); % load ceds64int.dll
end


open_mode = 0;
fhand = CEDS64Open(file_name,open_mode);
if fhand<0
    error('File not opened')
end
try
    fs = 1.0/(CEDS64ChanDiv(fhand, channel_number)*CEDS64TimeBase(fhand));
    maxTimeTicks = CEDS64ChanMaxTime( fhand, channel_number )+1; % +1 so the read gets the last point
    maxTime = CEDS64TicksToSecs(fhand,maxTimeTicks)+10;
    x = 0:1/fs:maxTime;
    
    
    alpha_wave = int16(draw_fake_spike(fs)*50000);
    
    
    %write random noise to all data points
    tic
    
    whitenoise_vec = int16(rand(1,length(x))*400);
    noise_vec = int16(Utilities.write_1f_noise(maxTime, fs)*1000);
    display(['time to write 1/f noise  =  ' num2str(toc)])
 
    %add random spikes
    random_spike_count = floor((maxTime-5))*10;
    random_spike_times = rand(1,random_spike_count)*(maxTime-5);
    random_spike_times=sort(random_spike_times(random_spike_times>2));
    random_spike_count = length(random_spike_times);
    tic
%     for index = 1:random_spike_count
%        [~,current_start] = min(abs(random_spike_times(index) - x)); 
%         current_bins = current_start:current_start+length(alpha_wave)-1;
%         noise_vec(current_bins) = noise_vec(current_bins)+alpha_wave;
%         %pause
%     end
    display(['time to add  random spikes  =  ' num2str(toc)])
    sTime =  0;
    sTick = CEDS64SecsToTicks( fhand, sTime );
    
    
    
    
    %write oscillation at every stim onset
    freq =80;
    
    oscillation_length  = floor(1.6*fs);

    
    %step_function =  int16(ones(1,step_length)* 30000);
    
    %simulated waveform to add to osillaton_vector at specific times

    for trial_index = 1:size(CompletedTrials.Stimulus(:,1))
   
        tic
        current_phase = rand*2*pi;
        current_phase_vector = 2*pi*x(1:oscillation_length)*freq+ current_phase;
        current_oscillation = int16(sin(current_phase_vector)* 500);
        
        current_phase_vector = mod(current_phase_vector,2*pi);
        
        trial_spike_count = 25;%randn*meanRate;
        
        [~,current_start] = min(abs(CompletedTrials.Stimulus(trial_index,1) - x));
        current_bins = current_start:current_start+oscillation_length-1;
        

        spike_bins = find(current_phase_vector>0 & current_phase_vector<0+.026);
        spike_bins = spike_bins(randperm(length(spike_bins)));
        for spike_index = 1:trial_spike_count
            current_spike_bins = spike_bins(spike_index):spike_bins(spike_index)+length(alpha_wave)-1;
            if max(current_spike_bins) <length(current_oscillation) & min(current_spike_bins)>0
                current_oscillation(current_spike_bins) =   current_oscillation(current_spike_bins) + alpha_wave;
            end
            %             if trial_index == 1
            %                 figure(1),plot(current_oscillation)
            %                 pause
            %             end
        end
  
        noise_vec(current_bins) = noise_vec(current_bins)+ current_oscillation;
        if mod(trial_index,100)==0
            display(['time to write 100 trials  =  ' num2str(toc)])
            display(['current trial number =  ' num2str(trial_index)])
        end
    end
    
    
    [ write_result] = CEDS64WriteWave( fhand, channel_number, noise_vec, sTick );
    %
    % figure(1),plot(x,wave_data)
    % wave_data = int16(wave_data);
    
    
    CEDS64Close(fhand);
catch ME
    display('error... aborting and closing file!')
    CEDS64Close(fhand);
    rethrow(ME)
    
end




function alpha_wave = draw_fake_spike(fs)

t = 0:1/fs:.001;
tau = .00003;
alpha_wave = t./tau .* exp(-(t./tau));
