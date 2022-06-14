function new_text_axis = add_figure_labels(axes_array, row_labels)
% add labels to figure for publication
%input
%   axes_array: array of handles to all the axes
%   row_labels: labels that are row specific
%returns: array of axes that hold figure labels

%figure(h),fig_location = get(gcf,'Position');

for index = 1:size(axes_array,2);
    for row_index = 1:size(axes_array,1)
        axes_array(1,index).Units = 'Inches';
        new_text_axis(row_index,index) = axes('Units','Inches')
        tp = get(axes_array(row_index,index),'InnerPosition');
        new_text_axis(row_index,index).InnerPosition = tp;
        axes(new_text_axis(row_index,index))
        new_text_axis(row_index,index).XLim = [0 1];
        new_text_axis(row_index,index).YLim = [0 1];
        new_text_axis(row_index,index).Color = [0 0 0];
        axis off
        new_text_axis(row_index,index).Position = [tp(1)-.5 tp(2)+1 .2 .2];
        text(.25,.5,[row_labels(row_index) num2str(index)],'Color',[0 0 0],'FontSize',9,'FontName','Arial')
    end
    
    
    
end