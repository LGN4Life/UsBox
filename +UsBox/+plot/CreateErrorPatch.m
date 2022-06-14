function [h,x2,y2] =CreateErrorPatch(x,y,error_vector,error_color)


if iscolumn(x)
    x=x';
end

if iscolumn(y)
    y=y';
end
if iscolumn(error_vector)
    error_vector=error_vector';
end
current_bins = isfinite(y);
x=x(current_bins);
y=y(current_bins);
error_vector = error_vector(:,current_bins);
x2 = [x fliplr(x)];
if size(error_vector,1)==1
    y2 = [y + error_vector fliplr(y - error_vector)];
elseif size(error_vector,1)==2
    y2 = [error_vector(1,:) fliplr(error_vector(2,:))];
else
    error('error vector dimensions must be either 1xn (symetric error bars) or 2xN (asymetric error bars)')
end
    
h =patch(x2,y2,error_color);
h.LineStyle='none';
h.FaceAlpha = .2;
h.EdgeColor='none';
