function axes_locations = set_figure_dimensions(fig_size,num_sp, draw_size, gap_size,offset)
%setup figure to a  user specified # of subplots, with user defined
%positions. When called, this function will operate on the current figure.
%input
%   
%   fig_size: requested size of figure (hxw). By default will move figure
%       to a new location on screen.
%   num_sp: [# rows of subplots, # columns]
%   draw_size: drawable area of each axis [Width Height]
%   gap_size: gap between axes [horizontal vertical]
%   offset: gap from edge of figure [from_left from_top]
%   axis_size: size of subplot axis (h,w)
%returns:
%   axes_positions: list of positions to place the subplots

%preallocate memory 
n =prod(num_sp);
axes_locations.inner = zeros(n,4);
axes_locations.outer = zeros(n,4);

%clear current figure


%change the size of figure to requested dimensions
h = gcf;
h = UsBox.plot.figure_resize(h,fig_size,'Inches');

%create an array of axes .
current_children = h.Children;

%At this point the figure will appear to have giant axis. But in reality,
%there is a stack of axes.

%determine where to place subplots, leaving user defined spacing
left_edge = gap_size(1):gap_size(1)+draw_size(1):(gap_size(1)+draw_size(1))*num_sp(2);
bottom_edge = fliplr(gap_size(2):gap_size(2)+draw_size(2):(gap_size(2)+draw_size(2))*num_sp(1));
figure(h)
sub_plot_num = 0;
for bottom_index = 1:length(bottom_edge)
    for left_index = 1:length(left_edge)
        sub_plot_num = sub_plot_num+1;

        ip = [left_edge(left_index)+offset(1)-gap_size(1)/2 bottom_edge(bottom_index)+ offset(2)-gap_size(2)/2 draw_size(1) draw_size(2)];
        
        axes_locations.outer(sub_plot_num,:) = [left_edge(left_index)+ offset(1) bottom_edge(bottom_index)+ offset(2) draw_size+gap_size];
        axes_locations.inner(sub_plot_num,:) = ip;
        

    end
    
    
    
    
end
