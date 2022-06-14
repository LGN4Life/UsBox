function BatchLoad(data_set,start_index,end_index,varargin)


%BATCHLOAD: Load in spike2 data from smr file to
% matlab struct.
%
%inputs : data_set = a struture that tells matlab how and where to find the
%smr files
%
%start_index = start row of the excel spreadsheet
%end_index = end row of the excel spreadsheet
%optional:
% get_time: true to get time information related to speed of file loading.
%       (default: false)

if length(varargin)>=1
    get_time = varargin{1};
else
    get_time = false;
    
end

filter_params.F_Deg = 6;
filter_params.target_subsample_frequency = 500;
filter_params.R = 50;
filter_params.fc =250;
%check to see if the CED library has been loaded. It seems this needs to be
%reloaded everytime you start matlab, but perhaps there is a way to make it
%load automatically at startup

if ~libisloaded('ceds64int')
    cedpath = 'C:\CEDMATLAB\CEDS64ML\'; % if no environment variable (NOT recommended)
    CEDS64LoadLib( cedpath ); % load ceds64int.dll
end





if ~exist('start_index','var')
    start_index = obj.ExcelRange(1);
end

if ~exist('end_index','var')
    end_index = obj.ExcelRange(2);
end

%read in file information from a properly formatted excel spreadsheet

[excel_data,read_time] = UsBox.Spike2.get_excel_data(data_set,start_index, end_index);
if get_time
    display(['Excel read time  = ' num2str(read_time)])
end

%true_row_index allows you to display the actual row from the excel spreadsheat,
%otherwise there would be a one-off error (the first row in the excel
%spreadsheet is the header line and is not counted).Useful if the program
%is crashing while loading a particular file
true_row_index = start_index:end_index;
end_index = size(excel_data,1);
start_index = 1;



for file_index =start_index:end_index
    

    

    pupil_data =[];
    
    
    
    
    if excel_data.Exclude(file_index)==0
        
        
        display(['Reading excel row ' num2str(true_row_index(file_index))])
        
        data = UsBox.Spike2.DetermineDirectoryNames(data_set,excel_data(file_index,:));
        
        %get additional parameters from par file (written by Spike2 when
        %data was collected)
        if ~contains(data.Parameters.FileNames.Spike2,'dark')
            data = UsBox.Spike2.LoadParFileInfo(data);
        else
            
            
            
        end
        
        


        
        
        
        
        fhand = UsBox.Spike2.OpenSmrFile([data.Parameters.FileNames.Spike2 '.smr']);
        fhand_par = UsBox.Spike2.OpenSmrFile([data.Parameters.FileNames.Spike2ParChan '.smr']);
        
        
        
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
                pupil_data.rate = excel_data.EyeTrackerRate(file_index);
                pupil_data = PupilSize.synch(pupil_data,data.Parameters.ParameterChannels.PupilData.Smr);
                pupil_data = pupil_data.data;
                pupil_data.size = double( pupil_data.pupil);
             
            else
                
                data.Parameters.ParameterChannels.PupilData=[];
                pupil_data=[];
            end
            

        else
            data.Parameters.PupilData = [];
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
        if sum(strcmp(data.Parameters.DataBase.Properties.VariableNames,'SpikeChannel'))>0
            if data.Parameters.DataBase.SpikeChannel >0
                
                [spike_times,read_time] = UsBox.Spike2.LoadSpikeTimes(fhand,data.Parameters.DataBase.SpikeChannel,data.Parameters.DataBase.WaveMark);
%                 [ data.SpikeData.WaveForms,data.SpikeData.WaveTimes ] =Spike2.GetSpikeWavemarks(fhand,data.Parameters.DataBase.SpikeChannel,data.Parameters.DataBase.WaveMark,...
%                     data.SpikeData.RawSpikeTimes);
%                 if max(data.SpikeData.RawSpikeTimes - data.SpikeData.WaveTimes)>0
%                     fprintf('problem loading wave forms. Script paused');
%                     pause
%                     
%                 else
%                     fprintf('Waveforms loaded successsfully! \n');
%                 end
                if get_time
                    fprintf('time to load spiking data = %f \n',read_time)
                end
                if get_time
                    fprintf('time to load spiking data = %f \n',read_time)
                end
            else
                spike_times =[];
                
            end
            
        else
            
            spike_times = [];
            
        end
        
       
        
        
        
        
        
        %load eye tracker channels
        if sum(strcmp(channel_info.names,'Eye X'))>0
            eye_pos = UsBox.Spike2.load_eye_tracker_channels(data,1);
        else
            eye_pos = [];
        end
        
        
        
        
        continuous_recording = ContinuousRecording;
        
        if sum(strcmp(data.Parameters.DataBase.Properties.VariableNames,'ContinuousChannel'))>0
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
            end
        end
        
        if sum(strcmp(data.Parameters.DataBase.Properties.VariableNames,'FiberLocation'))>0
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
                
                
            end
            
           % pause
            
        else
            data.Parameters.ParameterChannels.OptoParameters=[];
        end
        
        %[TrialParameters,data.CompletedTrials] = AlertTuning.TextKeyExtract(data);
        
        
        %%
        %format data for sql database
        
        
        
        %%
        %determine how the data needs to be processed and process it
        %calculate triggers and text markers
         [tuning_data, CompletedTrials, AllTrials] = UsBox.Spike2.get_trigger_info(data, spike_times);
        %%
        
        
        save_file = data.Parameters.FileNames.MatLab;
        tic
        save(save_file,'data','spike_times','continuous_recording','eye_pos','pupil_data','tuning_data','CompletedTrials','AllTrials')
        if get_time
            fprintf('time to save data = %f \n',read_time)
        end
        CEDS64Close(fhand);
        CEDS64Close(fhand_par);
       
    end
    
end




