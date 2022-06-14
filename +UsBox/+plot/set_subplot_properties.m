function axis_list = set_subplot_properties(h,property_name,property_value)
%changes a user defined axis property to a user defined value (for all axes
%on current figure)
%value
%input: handle to a figure or an array of handles to all axes on the current figure

if isa(h,'matlab.graphics.axis.Axes')
    axis_list = h;
elseif isa(h,'matlab.ui.Figure')
    axis_list = findall(h, 'type', 'axes');
    
else
    s1 = 'matlab.graphics.axis.Axes';
    s2 = 'matlab.ui.Figure';
    em = sprintf('invalid input, h must be either axes array (class = %s) or a handle to a figure (class = %s)',s1,s2);
    error(em);
    
    
end
axis_list = axis_list(:);
for index = 1:length(axis_list)
    set(axis_list(index),property_name,property_value)
    if contains(property_name,'Font')
        text_list = findall(axis_list(index),'Type','Text');
        for text_index =1:length(text_list)
            set(text_list(text_index),property_name,property_value)
        end
        
    end
    if strcmp(property_name,'Position')
        
        p = get(axis_list(index),'Position');
        %determine middle of figure (width)
        p(3:4) = property_value;
        set(axis_list(index),property_name,p)
        
    end
end