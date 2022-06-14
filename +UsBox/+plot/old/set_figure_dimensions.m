function [axes_array,h] = set_figure_dimensions(h,fig_size,num_sp, draw_size, gap_size,offset, font_size)
%setup figure to a  user specified # of subplots, with user defined
%positions
%input
%   h: handle to figure
%   fig_size: requested size of figure (hxw). By default will move figure
%       to a new location on screen.
%   num_sp: [# rows of subplots, # columns]
%   draw_size: drawable area of each axis [Width Height]
%   gap_size: gap between axes [horizontal vertical]
%   offset: gap from edge of figure [from_left from_top]
%   axis_size: size of subplot axis (h,w)
%returns:
%   axes_array: array of handles to created subplots


%clear current figure


%change the size of figure to requested dimensions
figure(h)
h = UsBox.plot.figure_resize(h,fig_size,'Inches');

%create an array of axes .
axes_array = UsBox.plot.create_subplots(h,num_sp(1),num_sp(2));
%At this point the figure will appear to have giant axis. But in reality,
%there is a stack of axes.

%determine where to place subplots, leaving user defined spacing
left_edge = gap_size(1):gap_size(1)+draw_size(1):(gap_size(1)+draw_size(1))*num_sp(2);
bottom_edge = fliplr(gap_size(2):gap_size(2)+draw_size(2):(gap_size(2)+draw_size(2))*num_sp(1));
figure(h)
for bottom_index = 1:length(bottom_edge)
    for left_index = 1:length(left_edge)
        
        
        %axes_array(bottom_index,left_index) = axes;
        set(axes_array(bottom_index,left_index),'Units','inches')
        ip = [left_edge(left_index)+offset(1)-gap_size(1)/2 bottom_edge(bottom_index)+ offset(2)-gap_size(2)/2 draw_size(1) draw_size(2)];
        set(axes_array(bottom_index,left_index),'OuterPosition',[left_edge(left_index)+ offset(1) bottom_edge(bottom_index)+ offset(2) draw_size+gap_size])
        set(axes_array(bottom_index,left_index),'InnerPosition',ip,'FontSize',font_size)
        
        %set the current axes
        axes(axes_array(bottom_index,left_index))
        xlabel('xlabel here','fontsize',font_size,'FontName','Arial')
        ylabel('ylabel here','fontsize',font_size,'FontName','Arial')

    end
    
    
    
    
end
