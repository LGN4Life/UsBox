function figure_manipulation_demo
% a simple demo to illustrate the use of UsBox.plot

%%
% set figure parameters
%c = matrix of colors to use each column. Each row will be applied to a
%different variable. In this example we will be plotting three variables. e.g., c(1,:) = [red green blue];
c(1,:) = [152 79 10]/255;
c(2,:) = [230 97 155]/255;
c(3,:) = [255 194 10]/255;

fig_size = [8.5 8]; % in inches
axes_num = [3 4];% [#rows # columns];
draw_size= [1 1]; %drawable area WxH, in inches
gap_size = [.75 .75]; %space between axes WxH, in inches
offset = [.5 1.5]; %offset from edge of figure WxH, in inches
font_size = 9; %fnt size for figures, in points
font_name = 'Arial';%font style for figures
figure(1),clf,

axes_array = UsBox.plot.set_figure_dimensions(gcf,fig_size,axes_num, draw_size, gap_size,offset,font_size);

%% using specific axes
%to set the current axis use: axes(handle_to_current_axis). 
%for example, let's set plot some data in the third row, second colum
axes(axes_array(3,2))
line_handle = plot(rand(1,100));
%turn the box off around the current plot
%after setting the current axis
%some properties such as box off are reset everytime you plot a new line,
%but we can avoid this by  setting hold to on
hold on
box off

%you can save a handle to the line plot, this allows you to alter the
%proerties of the line drawing as you see fit. However, the easier way is
%to pass the parametes as options when you call the line drawing
plot(rand(1,100),'color',[0 1 0])
%box off

% when plotting a bar sometimes the edges on the bars look ugly. They can
% be turned off
%plot some bar data in axes(1,3)
axes(axes_array(1,3))
bar_handle =  bar(rand(1,10),'EdgeAlpha',0,'FaceColor',[1 0 1])
%make sure the xtick labels are not rotated
axes_array(1,3).XAxis.TickLabelRotation = 0;



%UsBox.plot.delete_legend_bars(legend_icons);

%the line thickness of the plot (which does not include the line drawings
%which are considered 'Children') is controled by gca(set,'LineWidth')


set(gca,'LineWidth',3)
%or
axes_array(3,2).LineWidth = 2;
% or
current_axis = gca;
current_axis.LineWidth = 1;
%or 

%to set the line width of the , either pass it as an argument when you plot the
plot(rand(1,100),'color',[1 0 0])
box off

%axes children specifically refers to data (and other objects?) that have been plotted on a specific axis. 
%for example, axes_array(2,3) has no data plots, 
axes_array(2,3).Children
%let's plot three bar graphs
axes(axes_array(2,3))
bar(1:10,rand(10,3))
hold on
box off
%now we have 3 children
axes_array(2,3).Children
%If we add a legend
axes_array(2,3).XAxis.TickLabelRotation = 0;
axes_array(2,3).XTick = 0:2.5:10



%Importantly, the legend becomes a proeprty of the axis and child of the figure?
[legend_h,legend_icons] = legend('a','b','c');
UsBox.plot.delete_legend_bars(legend_icons)
%remove box around legend
legend_h.Box = 'off';

%set properties across the entire figure, such as font size
current_children = UsBox.plot.set_subplot_properties(gcf,'FontSize',font_size);
% ...and font type
UsBox.plot.set_subplot_properties(current_children,'FontName','Arial');

UsBox.plot.configure_legend_font_color(legend_icons,c)


%you can also smply resize the bars in the figure legend
d = [.05 .3];
[legend_h, legend_icons] = legend('a', 'b', 'c');
UsBox.plot.configure_legend_bars(legend_icons,d)
legend_h.Box = 'off';

%add labels to figure for publication
row_labels = 'ABCD';

UsBox.plot.add_figure_labels(axes_array, row_labels)

tic
toc