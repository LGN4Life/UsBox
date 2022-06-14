function [recording_table, excel_table,continuous_table] = create_recording_table(excel_table,conn)

table_name = 'recordings';
value_name = 'RecordingID';
m_recordingID = UsBox.ProjectManagement.get_max_value(table_name,value_name,conn);

RecordingID = m_recordingID+[1:length(excel_table.FileName)]';
excel_table = addvars(excel_table,RecordingID+m_recordingID,'NewVariableNames','RecordingID');

excel_table = addvars(excel_table,nan(length(excel_table.FileName),1),'NewVariableNames','ContinuousID');


unique_files = unique(excel_table.FileID);
unique_channels = unique(excel_table.ContinuousChannel);
m_continuousID = UsBox.ProjectManagement.get_max_value(table_name,value_name,conn);
cn = 0;
for file_index = 1:length(unique_files)
    
    for channel_index = 1:length(unique_channels)
        
        current = find(excel_table.FileID == unique_files(file_index) &  excel_table.ContinuousChannel == unique_channels(channel_index));
        if ~isempty(current)
            cn = cn+1;
            m_continuousID = m_continuousID+1;
            ChannelID(cn,1) = m_continuousID;
            ContinuousChannel(cn,1) =excel_table.ContinuousChannel(current(1));
            FileID(cn,1) = excel_table.FileID(current(1));
            excel_table.ContinuousID(current) = m_continuousID;
        end
            
        
    end
    
end

recording_table = table(RecordingID,excel_table.NeuronID,excel_table.FileID,excel_table.SpikeChannel,excel_table.WaveMark,...
    excel_table.WaveMarkGrade,excel_table.ContinuousID,excel_table.TimeRange,excel_table.Exclude);

recording_table.Properties.VariableNames = {'RecordingID','NeuronId', 'FileID', 'SpikeChannel', 'WaveMark',...
    'WaveMarkGrade','ContinuousID', 'TimeRange','Exclude'};

continuous_table = table(ChannelID,ContinuousChannel,FileID);

continuous_table.Properties.VariableNames = {'ContinuousID','ChannelNumber','FileID'};