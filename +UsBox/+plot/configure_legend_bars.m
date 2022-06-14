function configure_legend_bars(legend_icons,d)
%change the size of bars in legend
%list of icons in the legend. Will filter out the non-bar objects (e.g.,
%text, lines)
%input:
%   legend_icons: list of handles to the objects in the legend (second
%       output of the legend function
%   d: requested dimensions of the bars (HeightxWidth). Make sure the units
%       requested are those used by the legend (e.g., if you are trying to
%       get a 0.2 inch bar, make sure the legend units are "inches"

%get array of handles to bar objects
legend_bars = findobj(legend_icons,'Type','hggroup');
%bar dimensions
%bar_x = [L L R R L]
%bar_y = [B T T B B];
for index = 1:length(legend_bars)
    %get the current Y data that defines the bar height
    bar_y = get(legend_bars(index).Children,'YData');
    bar_x = get(legend_bars(index).Children,'XData');
    current_height = bar_y(2) - bar_y(1);

    bar_middle = [mean(bar_x([1 3])) mean(bar_y([1 3]))];
    new_bar_x = [bar_middle(1)-d(2)/2 bar_middle(1)-d(2)/2 bar_middle(1)+d(2)/2 bar_middle(1)+d(2)/2 bar_middle(1)-d(2)/2];
    new_bar_y = [bar_middle(2)-d(1)/2 bar_middle(2)+d(1)/2 bar_middle(2)+d(1)/2 bar_middle(2)-d(1)/2 bar_middle(2)-d(1)/2];
%     figure(2),fill(bar_x,bar_y,'k')
%     hold on
%     plot(bar_middle(1),bar_middle(2),'r+')
%     hold off
%     set(gca,'xlim',[-2 2])
%     set(gca,'ylim',[-2 2])
%     figure(3),fill(new_bar_x,new_bar_y,'k')
%     hold on
%     plot(bar_middle(1),bar_middle(2),'r+')
%     hold off
%     set(gca,'xlim',[-2 2])
%     set(gca,'ylim',[-2 2])
    

    set(legend_bars(index).Children,'YData',new_bar_y)
    set(legend_bars(index).Children,'XData',new_bar_x)
end