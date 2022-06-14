function deep_probe_xy

SF = .01;
TF=0;
step_size = .5;
%yc = -1.5;
%xc = 6.5;
horizontal.width = 9;
horizontal.height = .5;

horizontal.y_range = [-3 6];
horizontal.y = horizontal.y_range(1):step_size:horizontal.y_range(2);%yc:.5:yc+9;
horizontal.ori = 0;

vertical.width = .5;
vertical.height = 10;

vertical.x_range = [0 6];
vertical.x = vertical.x_range(1):step_size:vertical.x_range(2);%xc:-.5:xc-5;
vertical.ori = 90;

vertical.y = mean(horizontal.y);
horizontal.x = mean(vertical.x);

order = [zeros(1,2*length(vertical.x)), ones(1,2*length(horizontal.y))];
positions = cat(2,repmat(vertical.x,1,2),repmat(horizontal.y,1,2));
phase =repmat([0 180],1,length(order)/2);
r = randperm(length(order));
fid = fopen('Y:\BakersDozen\deep_probe_xy3.txt','w');

bar_string=' --wh ';
position_string = ' -Z ';
ori_string = ' -O ';
phase_string  = ' -P ';
sf_string  = ' -S ';
tf_string  = ' -T ';
for index = 1:length(r)
   switch order(r(index))
       case 0
           % vertical bar
           bar_string = cat(2,bar_string, sprintf('%.2f,%.2f,', vertical.width, vertical.height));
           position_string = cat(2,position_string, sprintf('%.2f,%.2f,',positions(r(index)), vertical.y));
           ori_string = cat(2,ori_string, sprintf('%.0f,',vertical.ori));
           fprintf('vertical bar at : x = %.2f, y = %.2f\n',positions(r(index)), vertical.y)
          
       case 1
           % horizontal bar
           bar_string = cat(2,bar_string, sprintf('%.2f,%.2f,', horizontal.width, horizontal.height));
           position_string = cat(2,position_string, sprintf('%.2f,%.2f,%.2f',horizontal.x, positions(r(index))));
           ori_string = cat(2,ori_string, sprintf('%.0f,',horizontal.ori));
           fprintf('horizontal bar at : x = %.2f, y = %.2f\n',horizontal.x, positions(r(index)))
       otherwise
           error('invalid trial type: %d\n',r(index))
       
   end
   phase_string = cat(2,phase_string, sprintf('%.0f,',phase(r(index))));
   sf_string = cat(2,sf_string, sprintf('%.2f,',SF));
   tf_string = cat(2,tf_string, sprintf('%.2f,',TF));
end
full_string = cat(2,'"',bar_string(1:end-1),position_string(1:end-1),ori_string(1:end-1),phase_string(1:end-1),sf_string(1:end-1),tf_string(1:end-1),'"');
fprintf(fid,full_string)
fclose(fid);