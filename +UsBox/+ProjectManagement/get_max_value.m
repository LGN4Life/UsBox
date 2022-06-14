function m = get_max_value(table_name,value_name,conn)



neurons = sqlread(conn,table_name);

if isempty(neurons)
    m= 0;
else
    
    m = max(neurons.(value_name));
end
