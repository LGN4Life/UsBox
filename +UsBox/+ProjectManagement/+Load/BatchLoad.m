function BatchLoad(data_table, data_set, varargin)


%BATCHLOAD: Load in spike2 data from smr file to
% MatLab struct.
%
%inputs : data_table = table generated by MySql
%
%start_index = start row of the excel spreadsheet
%end_index = end row of the excel spreadsheet
%optional:
% get_time: true to get time information related to speed of file loading.
%       (default: false)




filter_params.F_Deg = 6;
filter_params.target_subsample_frequency = 500;
filter_params.R = 50;
filter_params.fc =250;
%check to see if the CED library has been loaded. It seems this needs to be
%reloaded everytime you start MatLab, but perhaps there is a way to make it
%load automatically at startup

if ~libisloaded('ceds64int')
    cedpath = 'C:\CEDMatLab\CEDS64ML\'; % if no environment variable (NOT recommended)
    CEDS64LoadLib( cedpath ); % load ceds64int.dll
end





if length(varargin)>=1
    start_index = varargin{1};
else
    start_index = 1;
end

if length(varargin)>=2
    end_index = varargin{2};
else
    end_index = size(data_table,1);
end

if length(varargin)>=3
    get_time = varargin{3};
else
    get_time = true
end



for file_index =start_index:end_index
    
    
    
    
    pupil_data =[];
    
    CEDS64CloseAll
    
    
    if data_table.Exclude(file_index)==0
        
        
        display(['Reading excel row ' num2str(file_index)])
        
        %data = UsBox.Spike2.DetermineDirectoryNames(data_set,data_table(file_index,:));
        data = UsBox.ProjectManagement.Load.DetermineDirectoryNames(data_table(file_index,:), data_set);
        %get additional parameters from par file (written by Spike2 when
        %data was collected)
        if ~contains(data.Parameters.FileNames.Spike2,'dark')
            data = UsBox.ProjectManagement.Load.LoadParFileInfo(data);
        else
            
            
            
        end
        
        
        
        
        
        
        
        
        fhand = UsBox.Spike2.OpenSmrFile([data.Parameters.FileNames.Spike2]);
        fhand_par = UsBox.Spike2.OpenSmrFile([data.Parameters.FileNames.Spike2ParChan]);
        
        
        
        tic
        
        [channel_info] = UsBox.Spike2.GetChannelLabels(fhand);
        [channel_info_par] = UsBox.Spike2.GetChannelLabels(fhand_par);
        
        %load text channel
        
        text_channel_number = channel_info_par.number(strcmp(channel_info_par.names,'TextMark'));
        
        if ~isempty(text_channel_number)
            data.Parameters.ParameterChannels.TextParameters = UsBox.Spike2.LoadTextChannel(fhand_par,text_channel_number);
        else
            data.Parameters.ParameterChannels.TextParameters = [];
        end
        
        pupil_channel_number = channel_info_par.number(contains(channel_info_par.names,'EyeFileP'));
        
        if exist([data.Parameters.FileNames.Spike2ParChan '.eyd'],'file') == 2
            if isempty(pupil_channel_number)
                pupil_channel_number = channel_info_par.number(strcmp(channel_info_par.names,'Laser On'));
            end
            if ~isempty(pupil_channel_number)
                
                data.Parameters.ParameterChannels.PupilData.Smr= UsBox.Spike2.LoadKeyboardChannel(fhand_par,pupil_channel_number);
                %remove info from laser triggers
                pupil_info = find(cell2mat(data.Parameters.ParameterChannels.PupilData.Smr.markers)>1);
                data.Parameters.ParameterChannels.PupilData.Smr.markers = data.Parameters.ParameterChannels.PupilData.Smr.markers(pupil_info);
                data.Parameters.ParameterChannels.PupilData.Smr.timestamps = data.Parameters.ParameterChannels.PupilData.Smr.timestamps(pupil_info);
                pupil_data = PupilSize.eydexp([data.Parameters.FileNames.Spike2 '.eyd']);
                pupil_data.rate = data_table.EyeTrackerRate(file_index);
                pupil_data = PupilSize.synch(pupil_data,data.Parameters.ParameterChannels.PupilData.Smr);
                pupil_data = pupil_data.data;
                pupil_data.size = double( pupil_data.pupil);
                pupil_file_name = [ data.Parameters.FileNames.MatLab '\pupil_data'];
                save(pupil_file_name,'pupil_data')
                
            else
                
                data.Parameters.ParameterChannels.PupilData=[];
                pupil_data=[];
                pupil_file_name = [ data.Parameters.FileNames.MatLab '\pupil_data'];
                save(pupil_file_name,'pupil_data')
            end
            
            
        else
            data.Parameters.PupilData = [];
            pupil_file_name = [ data.Parameters.FileNames.MatLab '\pupil_data'];
            save(pupil_file_name,'pupil_data')
        end
        
        %load keyboard channel
        keyboard_channel_number = channel_info_par.number(strcmp(channel_info_par.names,'Keyboard'));
        if ~isempty(keyboard_channel_number)
            data.Parameters.ParameterChannels.KeyboardParameters= UsBox.Spike2.LoadKeyboardChannel(fhand_par,keyboard_channel_number);
        else
            data.Parameters.ParameterChannels.KeyboardParameters = [];
        end
        
        
        if get_time
            fprintf('time to load channel info and accessary channels = %f\n',toc)
        end
        
        
        %load fixation times
        
        %depending on the type of data, the fixation channel may have
        %various names
        fixation_channel_number = channel_info_par.number(strcmp(channel_info_par.names,'Fixpt'));
        if isempty(fixation_channel_number)
            fixation_channel_number = channel_info_par.number(strcmp(channel_info_par.names,'FixPt'));
        end
        if isempty(fixation_channel_number)
            fixation_channel_number = channel_info_par.number(strcmp(channel_info_par.names,'Fix'));
        end
        if ~isempty(fixation_channel_number)
            data.Parameters.ParameterChannels.FixationParameters.timestamps  = UsBox.AlertTuning.LoadLevelTimeStamps(fixation_channel_number,fhand_par);
        else
            data.Parameters.ParameterChannels.FixationParameters = [];
        end
        
        
        %load stim times
        
        stim_channel_number = channel_info_par.number(strcmp(channel_info_par.names,'Stim'));
        if ~isempty(stim_channel_number)
            data.Parameters.ParameterChannels.StimulusParameters.timestamps  = UsBox.Spike2.LoadLevelTimeStamps(stim_channel_number,fhand_par);
        else
            data.Parameters.ParameterChannels.StimulusParameters =[];
        end
        
        
        
        
        
        
        
        %load spike times
        if isfield(data.Parameters.DataBase,'SpikeChannel')
            if data.Parameters.DataBase.SpikeChannel >0
                
                [spike_times,read_time] = UsBox.Spike2.LoadSpikeTimes(fhand,data.Parameters.DataBase.SpikeChannel,data.Parameters.DataBase.WaveMark);
                if get_time
                    fprintf('time to load spiking data = %f \n',read_time)
                end
                if get_time
                    fprintf('time to load spiking data = %f \n',read_time)
                end
                
                spike_file_name = [ data.Parameters.FileNames.MatLab 'spike_channel_' num2str(data.Parameters.DataBase.SpikeChannel) '_' num2str(data.Parameters.DataBase.WaveMark)];
                
                save(spike_file_name,'spike_times')
            end
            
        else
            spike_times =[];
            save(spike_file_name,'spike_times')
        end
        
        
        
        
        
        
        
        
        
        %load eye tracker channels
        if sum(strcmp(channel_info.names,'Eye X'))>0
            eye_pos = UsBox.Spike2.load_eye_tracker_channels(data,1);
        else
            eye_pos = [];
        end
        
        
        
        
        continuous_recording = ContinuousRecording;
        
        if isfield(data.Parameters.DataBase,'ContinuousChannel')
            if data.Parameters.DataBase.ContinuousChannel>0
                [continuous_recording,read_time] = UsBox.Spike2.LoadContinuous(fhand,data.Parameters.DataBase.ContinuousChannel,continuous_recording);
                continuous_recording.Y = double(continuous_recording.Y);
                if get_time
                    fprintf('time to load lfp data = %f \n',read_time)
                end
                tic
                %preprocess LFP data so your not wasting hard drive sspace
                continuous_recording = continuous_recording.FilterData(filter_params);
                continuous_recording = continuous_recording.SubsampleData(filter_params.target_subsample_frequency);
                continuous_recording = continuous_recording.Remove60Hz;
                fprintf('time to process lfp data = %f \n',toc)
                continuous_file_name = [ data.Parameters.FileNames.MatLab '\continuous_channel_' num2str(data.Parameters.DataBase.ContinuousChannel)];
                
                save(continuous_file_name,'continuous_recording')
            else
                continuous_recording =[];
                save(continuous_file_name,'continuous_recording')
                
            end
            
            
        else
            continuous_recording =[];
            save(continuous_file_name,'continuous_recording')
        end
        
        if isfield(data.Parameters.DataBase,'FiberLocation') | ~isfield(data.Parameters.DataBase,'FiberLocation')
            dig_channel_number = channel_info_par.number(strcmp(channel_info_par.names,'DigMark'));
            if isempty(dig_channel_number)
                dig_channel_number = channel_info_par.number(strcmp(channel_info_par.names,'Laser On'));
            end
            if ~isempty(dig_channel_number)
                data.Parameters.ParameterChannels.OptoParameters= UsBox.Spike2.LoadKeyboardChannel(fhand_par,dig_channel_number);
                
            else
                data.Parameters.ParameterChannels.OptoParameters = [];
            end
            opto_channel_number = channel_info.number(contains(channel_info.names,'Optic'));
            if isempty(opto_channel_number)
                opto_channel_number = channel_info.number(contains(channel_info.names,'OptoWF'));
            end
            opto_continuous = ContinuousRecording;
            if ~isempty(opto_channel_number)
                [opto_continuous,read_time] = UsBox.Spike2.LoadContinuous(fhand,opto_channel_number,opto_continuous);
                opto_continuous.Y = double(opto_continuous.Y);
                opto_continuous = opto_continuous.SubsampleData(500);
                data.opto_continuous = opto_continuous.Y;
                
            else
                % data.Parameters.ParameterChannels.OptoParameters=[];
                
            end
            
            % pause
            
        else
            data.Parameters.ParameterChannels.OptoParameters=[];
        end
        
        %[AllTrials,data.CompletedTrials] = AlertTuning.TextKeyExtract(data);
        
        
        %%
        %format data for sql database
        
        
        
        %%
        %determine how the data needs to be processed and process it
        %calculate triggers and text markers
        
        AllTrials =[];
        CompletedTrials = [];
        tuning_data = [];
        if contains(data.Parameters.FileNames.MatLab,'dark') | contains(data.Parameters.FileNames.MatLab,'ps') | ...
                contains(data.Parameters.FileNames.MatLab,'vid')
            
            
        elseif contains(data.Parameters.FileNames.MatLab,'imgs')
            [AllTrials,CompletedTrials] = NatImage.TextKeyExtract(data.Parameters);
            tuning_data=[];
        elseif contains(data.Parameters.FileNames.MatLab,'atn')
            if contains(data.Parameters.FileNames.MatLab,'18') | contains(data.Parameters.FileNames.MatLab,'19') |contains(data.Parameters.FileNames.MatLab,'20')...
                    | contains(data.Parameters.FileNames.MatLab,'21') | contains(data.Parameters.FileNames.MatLab,'22') | contains(data.Parameters.FileNames.MatLab,'23')
                [AllTrials,CompletedTrials] = Attention.TextKeyExtract(data.Parameters);
            else
                [AllTrials,CompletedTrials] = Attention_2014.TextKeyExtract(data.Parameters);
            end
            
        elseif contains(data.Parameters.FileNames.MatLab,'star')
            [AllTrials,CompletedTrials] = StarStim.TextKeyExtract(data.Parameters);
        elseif contains(data.Parameters.FileNames.MatLab,'tun')
            stim_list = UsBox.bakers.get_stim_list(data.Parameters.TuningParameters.ValuesAre);
            [AllTrials,CompletedTrials] = UsBox.bakers.TextKeyExtract(data.Parameters);
            
            CompletedTrials.stim_list = stim_list;
            
            AllTrials.stim_list = stim_list;
        else
            [tuning_data, CompletedTrials, AllTrials] = UsBox.Spike2.get_trigger_info(data, spike_times);
        end
        parameters = data.Parameters;
        parameters_file_name = [ data.Parameters.FileNames.MatLab 'parameters'];
        save(parameters_file_name,'tuning_data','AllTrials','CompletedTrials','parameters')
        
        
        
        
        %%
        
        
        CEDS64Close(fhand);
        CEDS64Close(fhand_par);
        tic
        toc
        
    else
        
        %         spike_times = [];
        %         save(spike_file_name,'spike_times')
    end
    
end

end




