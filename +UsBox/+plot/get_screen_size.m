function ss = get_screen_size(varargin)
%returns the size of your screen (default = pixels)
%input:
%   screen_units: (default 'pixels') unit for screen size (e.g., inches)
%   set_flag: (default false) true = sets root object (e.g., your screen)
%   to the screen_units. false = ensures the root object units are pixels.
%   If the root object units are changes, this not not effect figure properties
%   such as 'Position'. To set figure units, set(gcf,'Units','inches')


if length(varargin)>=1
    screen_units = varargin{1};
    
else
    screen_units = 'pixels';
end
if length(varargin)>=2
    set_flag = varargin{2};
else
    set_flag = false;
end
%Sets the units of your root object (screen) to inches
set(0,'units',screen_units)
%Obtains this inch information
ss = get(0,'screensize');

if ~set_flag
    set(0,'units','pixels')
end
