function h = create_subplots(h,r,c);
%creates an array of axes
%input
%   h = handle to figure
%   r = # of rows
%   c = # of columns


figure(h),clf
t=0;
for row_index  = 1:r
    for column_index = 1:c
        t=t+1;
        %will by default create an axis that is large and in the center of
        %the current figure
        h(row_index,column_index) = subplot(r,c,t);
    end
    
    
    
    
    
end

