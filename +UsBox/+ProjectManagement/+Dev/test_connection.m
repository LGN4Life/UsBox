
username = 'root';
password = "&7ccV%9h6!+)GVR-68nyNMRN";

conn = database('test_data',username,password);

sqlquery = 'DROP table neurons;';
execute(conn,sqlquery)
% neuron_id = 1:3;
% species = {'Duck', 'Monkey', 'Pig'};
% 
% neuron_table = table(neuron_id', species', 'VariableNames',{'NeuronID','Species'});
% 
% sqlwrite(conn,'matlab',neuron_table)


