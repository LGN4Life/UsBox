function data = plot_xypos(data,TrialLogical)

tic
gauss_x =-20:20;
gauss_filter = normpdf(gauss_x,0, .5);




unique_x = unique(data.combo_list(:,1));
unique_y = unique(data.combo_list(:,2));

for x_index = 1:length(unique_x)
    for y_index = 1:length(unique_y)
        [x_index y_index]
        current_trials = data.combo_list(data.TrialIV,1)==unique_x(x_index)...
            & data.combo_list(data.TrialIV,2)==unique_y(y_index) & TrialLogical;
        response_grid.mean(x_index,y_index) = nanmean(data.TrialMean(current_trials));
        
    end
    
end


grid_x = unique_x-min(unique_x);
grid_y = unique_x-min(unique_x);
figure,imagesc(response_grid.mean), colorbar
set(gca,'xtick',[1 3 5])
set(gca,'ytick',[1 3 5])
set(gca,'xticklabel',[grid_x(1) grid_x(3) grid_x(5)])
set(gca,'yticklabel',[grid_y(1) grid_y(3) grid_y(5)])
grid_x =linspace(min(grid_x),max(grid_x),200);
grid_x = floor(10*grid_x)/10;

grid_y =linspace(min(grid_y),max(grid_y),200);
grid_y = floor(10*grid_y)/10;
response_grid.smooth_mean = imresize(response_grid.mean, 40, 'bicubic');
figure,imagesc(response_grid.smooth_mean),colorbar
set(gca,'xtick',[1 50 100 150 200])
set(gca,'ytick',[1 50 100 150 200])
set(gca,'xticklabel',[grid_x(1) grid_x(50) grid_x(100) grid_x(150) grid_x(200)])
set(gca,'yticklabel',[grid_y(1) grid_y(50) grid_y(100) grid_y(150) grid_y(200)])
xlabel('xpos (visual degrees)')
xlabel('ypos (visual degrees)')






 













