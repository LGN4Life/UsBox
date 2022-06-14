function BatchLoadSpike2(data_set,start_index,end_index,varargin)


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

[column_names,excel_data,read_time] =Spike2.get_excel_data(data_set,start_index, end_index);
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
    
    [current_excel_line] = Spike2.BuildExcelDataField(column_names,excel_data(file_index,:));
    

    pupil_data =[];
    
    
    
    
    if current_excel_line.Exclude==0
        
        
        
        
        data = AlertTuning.DetermineDirectoryNames(data_set,current_excel_line);
        
        %get additional parameters from par file (written by Spike2 when
        %data was collected)
        
        if exist(data.Parameters.FileNames.ParFile,'file') == 2
            data = Spike2.LoadParFileInfo(data);% load info from par file:  a text file created during experiment
        else
            data.Parameters.StimulusParameters.TF=nan;
        end
        
        


        
        
        display(['Reading excel row ' num2str(true_row_index(file_index))])
        
        fhand = Spike2.OpenSmrFile(data.Parameters.FileNames.Spike2);
        fhand_par = Spike2.OpenSmrFile(data.Parameters.FileNames.Spike2ParChan);
        
        
        
        tic
        
        [channel_info] = Spike2.GetChannelLabels(fhand);
        [channel_info_par] = Spike2.GetChannelLabels(fhand_par);
        
        %load text channel
        
        text_channel_number = channel_info_par.number(strcmp(channel_info_par.names,'TextMark'));
        
        if ~isempty(text_channel_number)
            data.Parameters.ParameterChannels.TextParameters = Spike2.LoadTextChannel(fhand_par,text_channel_number);
        else
            data.Parameters.ParameterChannels.TextParameters = [];
        end
        
        pupil_channel_number = channel_info_par.number(contains(channel_info_par.names,'EyeFileP'));

        if exist(data.Parameters.FileNames.Eyd,'file') == 2
            if isempty(pupil_channel_number)
                pupil_channel_number = channel_info_par.number(strcmp(channel_info_par.names,'Laser On'));
            end
            if ~isempty(pupil_channel_number)
                
                data.Parameters.ParameterChannels.PupilData.Smr= Spike2.LoadKeyboardChannel(fhand_par,pupil_channel_number);
                %remove info from laser triggers
                pupil_info = find(cell2mat(data.Parameters.ParameterChannels.PupilData.Smr.markers)>1);
                data.Parameters.ParameterChannels.PupilData.Smr.markers = data.Parameters.ParameterChannels.PupilData.Smr.markers(pupil_info);
                data.Parameters.ParameterChannels.PupilData.Smr.timestamps = data.Parameters.ParameterChannels.PupilData.Smr.timestamps(pupil_info);
                pupil_data = PupilSize.eydexp(data.Parameters.FileNames.Eyd);
                if strcmp(current_excel_line.AnimalName,'Tomi')
                    pupil_data.rate = 119.6520;
                elseif strcmp(current_excel_line.AnimalName,'Rubi')
                    
                   pupil_data.rate =119.6525 ;
                end
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
            data.Parameters.ParameterChannels.KeyboardParameters= Spike2.LoadKeyboardChannel(fhand_par,keyboard_channel_number);
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
            data.Parameters.ParameterChannels.FixationParameters.timestamps  = AlertTuning.LoadLevelTimeStamps(fixation_channel_number,fhand_par);
        else
            data.Parameters.ParameterChannels.FixationParameters = [];
        end
        
        
        %load stim times
        
        stim_channel_number = channel_info_par.number(strcmp(channel_info_par.names,'Stim'));
        if ~isempty(stim_channel_number)
            data.Parameters.ParameterChannels.StimulusParameters.timestamps  = AlertTuning.LoadLevelTimeStamps(stim_channel_number,fhand_par);
        else
            data.Parameters.ParameterChannels.StimulusParameters =[];
        end
        
        
  
        
        
        
        
        %load spike times
        if isfield(data.Parameters.ExcelData,'SpikeChannel')
            if data.Parameters.ExcelData.SpikeChannel >0
                
                [data.SpikeData.RawSpikeTimes,read_time] = Spike2.LoadSpikeTimes(fhand,data.Parameters.ExcelData.SpikeChannel,data.Parameters.ExcelData.WaveMark);
                [ data.SpikeData.WaveForms,data.SpikeData.WaveTimes ] =Spike2.GetSpikeWavemarks(fhand,data.Parameters.ExcelData.SpikeChannel,data.Parameters.ExcelData.WaveMark,...
                    data.SpikeData.RawSpikeTimes);
                if max(data.SpikeData.RawSpikeTimes - data.SpikeData.WaveTimes)>0
                    fprintf('problem loading wave forms. Script paused');
                    pause
                    
                else
                    fprintf('Waveforms loaded successsfully! \n');
                end
                if get_time
                    fprintf('time to load spiking data = %f \n',read_time)
                end
                if get_time
                    fprintf('time to load spiking data = %f \n',read_time)
                end
            else
                data.SpikeData = [];
                
            end
            
        else
            
            data.SpikeData = [];
            
        end
        
       
        
        
        
        
        
        %load eye tracker channels
        
        eye_pos = Spike2.load_eye_tracker_channels(data,1);
        
        
        
        
        continuous_recording = ContinuousRecording;
        
        if isfield(data.Parameters.ExcelData,'ContinuousChannel')
            if data.Parameters.ExcelData.ContinuousChannel>0
                [continuous_recording,read_time] = AlertTuning.LoadContinuous(fhand,data.Parameters.ExcelData.ContinuousChannel,continuous_recording);
                continuous_recording.Y = double(continuous_recording.Y);
                if get_time
                    fprintf('time to load lfp data = %f \n',read_time)
                end
                tic
                %preprocess LFP data so your not wasting hard drive sspace
                continuous_recording = continuous_recording.FilterData;
                continuous_recording = continuous_recording.SubsampleData;
                continuous_recording = continuous_recording.Remove60Hz;
                fprintf('time to process lfp data = %f \n',toc)
            end
        end
        
        if isfield(data.Parameters.ExcelData,'FiberLocation')
            dig_channel_number = channel_info_par.number(strcmp(channel_info_par.names,'DigMark'));
            if isempty(dig_channel_number)
                dig_channel_number = channel_info_par.number(strcmp(channel_info_par.names,'Laser On'));
            end
            if ~isempty(dig_channel_number)
                data.Parameters.ParameterChannels.OptoParameters= Spike2.LoadKeyboardChannel(fhand_par,dig_channel_number);
     
            else
                data.Parameters.ParameterChannels.OptoParameters = [];
            end
            opto_channel_number = channel_info.number(contains(channel_info.names,'Optic'));
            if isempty(opto_channel_number)
                opto_channel_number = channel_info.number(contains(channel_info.names,'OptoWF'));
            end
            opto_continuous = ContinuousRecording;
            if ~isempty(opto_channel_number)
                [opto_continuous,read_time] = Attention_v8.LoadContinuous(fhand,opto_channel_number,opto_continuous);
                opto_continuous.Y = double(opto_continuous.Y);
                opto_continuous = opto_continuous.SubsampleData;
                data.opto_continuous = opto_continuous.Y;
                
            else
                
                
            end
            
           % pause
            
        else
            data.Parameters.ParameterChannels.OptoParameters=[];
        end
        
        %[TrialParameters,data.CompletedTrials] = AlertTuning.TextKeyExtract(data);
      
        
        
        
        save_file = data.Parameters.FileNames.MatLab;
        tic
        save(save_file,'data','continuous_recording','eye_pos','pupil_data')
        if get_time
            fprintf('time to save data = %f \n',read_time)
        end
        CEDS64Close(fhand);
        CEDS64Close(fhand_par);
        
    end
    
end




