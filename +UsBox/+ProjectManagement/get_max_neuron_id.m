function m = get_max_neuron_id(conn)



neurons = sqlread(conn,'neurons');

if isempty(neurons)
    m= 0;
else
    
    m = max(neurons.NeuronID);
end
