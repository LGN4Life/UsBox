function configure_legend_font_color(legend_icons,c)


legend_text = findobj(legend_icons,'Type','text');

for index = 1:length(legend_text)
    
    legend_text(index).Color = c(index,:);
    
end