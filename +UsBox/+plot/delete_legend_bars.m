function delete_legend_bars(legend_icons)
%remove bars from legend

%get array of handles to bar objects
legend_bars = findobj(legend_icons,'Type','hggroup');
legend_lines = findobj(legend_icons,'Type','Line');
legend_patch = findobj(legend_icons,'Type','Patch');

legend_objects = cat(1,legend_bars,legend_lines,legend_patch);

for index = 1:length(legend_objects)
   delete(legend_objects(index))
end



% legend_lines = findobj(legend_icons,'Type','line');
% 
% for index = 1:length(legend_lines)
%    delete(legend_lines(index))
% end