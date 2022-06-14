function h = figure_resize(h, s,varargin)
%control the size of a matlab figure
%input:
%   h = handle to figure 
%   s = requested figure size (hxw)
%   units = units of size (default = inches). Will change the Units of the
%   figure to this value

if length(varargin)>=1
    units = varargin{1};
else
    units = 'inches';
end

set(h,'Units',units)

p =get(h,'Position');
set(gcf,'Position',[p(1) p(2) s])




