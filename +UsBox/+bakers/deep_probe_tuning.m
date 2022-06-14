function deep_probe_tuning


default_values = [100 1 90 5]; %[contrast sf ori tf]
C = [ 12.5 25 50 100];

l = log10(.25);
h = log10(7);
steps = 7;
SF = 10.^(l:(h-l)/steps:h);
TF = [2 4 8 16 32];
ori = 0:360/12:360;
ori = ori(1:end-1);

order = [zeros(1,length(C)), ones(1,length(SF)), 2*ones(1,length(ori)) , 3*ones(1,length(TF))];
values = cat(2,C,SF,ori, TF);
r = randperm(length(order));
fid = fopen('Y:\BakersDozen\deep_probe_tuning2.txt','w');

contrast_string=[' -C '];
sf_string=[' -S '];
ori_string=[' -O '];
tf_string=[' -T '];
for index = 1:length(r)
   switch order(r(index))
       case 0
           % contrast trial
           contrast_string = cat(2,contrast_string, sprintf('%.2f,',values(r(index))));
           sf_string = cat(2,sf_string, sprintf('%.2f,',default_values(2)));
           ori_string = cat(2,ori_string, sprintf('%.0f,',default_values(3)));
           tf_string = cat(2,tf_string, sprintf('%.2f,',default_values(4)));
       case 1
           % sf trial
           contrast_string = cat(2,contrast_string, sprintf('%.2f,',default_values(1)));
           sf_string = cat(2,sf_string, sprintf('%.2f,',values(r(index))));
           ori_string = cat(2,ori_string, sprintf('%.0f,',default_values(3)));
           tf_string = cat(2,tf_string, sprintf('%.2f,',default_values(4)));
       case 2
           %ori trial
           contrast_string = cat(2,contrast_string, sprintf('%.2f,',default_values(1)));
           sf_string = cat(2,sf_string, sprintf('%.2f,',default_values(2)));
           ori_string = cat(2,ori_string, sprintf('%.0f,',values(r(index))));
           tf_string = cat(2,tf_string, sprintf('%.2f,',default_values(4)));
       case 3
           %tf trial
           contrast_string = cat(2,contrast_string, sprintf('%.2f,',default_values(1)));
           sf_string = cat(2,sf_string, sprintf('%.2f,',default_values(2)));
           ori_string = cat(2,ori_string, sprintf('%.2f,',default_values(3)));
           tf_string = cat(2,tf_string, sprintf('%.0f,',values(r(index))));
       otherwise
           error('invalid trial type: %d\n',r(index))
   end

end
full_string = cat(2,'"',contrast_string(1:end-1), sf_string(1:end-1),ori_string(1:end-1),tf_string(1:end-1),'"');
fprintf(fid,full_string);
fclose(fid);