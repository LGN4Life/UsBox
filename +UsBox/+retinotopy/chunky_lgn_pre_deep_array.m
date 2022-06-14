function chunky_lgn_pre_deep_array

electrode_pitch = 25;
probe_x = 0:electrode_pitch:electrode_pitch*127;
%probe_x = sort([probe_x fliplr(probe_x)+25]);
probe_x =probe_x /1000;
figure(1),clf
h(1) = subplot(1,3,1);hold on
box off
axis square
xlabel('electrode travel (mm)')
ylabel(['retinotopic displace' char(176)])

h(2) = subplot(1,3,2); hold on
box off
axis square
axis([-10 10 -5 20]) 
xlabel(['azimuth' char(176)])
ylabel(['elevation' char(176)])
h(3) = subplot(1,3,3); hold on
box off
axis square
xlabel('probe channel number')
ylabel(['retinotopic displacement' char(176)])

%% 220510 , pen = e,3
Fix = [7 0];
filename= 'C:\Henry\Projects\Pulvinar\Cylinder\Chunky\chunky lgn mapping.xlsx';
opts = spreadsheetImportOptions;
opts.Sheet = '220510';
opts.VariableNames = [{'X'},{'Y'},{'Z'}];
opts.DataRange = 'a4:c20';
opts.VariableTypes =  {'double','double','double'} ;

T = readtable(filename,opts);

electrode_travel = T.Z - min(T.Z);
displacement = sqrt((T.X-T.X(1)).^2+ (T.Y-T.Y(1)).^2);
axes(h(1)),plot(electrode_travel,displacement,'o')
ylabel(['retinotopic displace' char(176)])
xlabel('electrode travel (mm)')
set(gca,'ylim',[0 20])

axes(h(2)),plot(T.X -Fix(1),T.Y-Fix(2),'-o')

electrode_travel = T.Z - min(T.Z);
displacement = sqrt((T.X-T.X(1)).^2+ (T.Y-T.Y(1)).^2);

valid_probe_x = probe_x(probe_x<=max(electrode_travel));
displacement_probe = interp1(electrode_travel,displacement,valid_probe_x);
axes(h(3)),plot(displacement_probe) 
%% 220510 , pen = e,2

filename= 'C:\Henry\Projects\Pulvinar\Cylinder\Chunky\chunky lgn mapping.xlsx';
opts = spreadsheetImportOptions;
opts.Sheet = '220511';
opts.VariableNames = [{'X'},{'Y'},{'Z'}];
opts.DataRange = 'a3:c27';
opts.VariableTypes =  {'double','double','double'} ;

T = readtable(filename,opts);

electrode_travel = T.Z - min(T.Z);
displacement = sqrt((T.X-T.X(1)).^2+ (T.Y-T.Y(1)).^2);

valid_probe_x = probe_x(probe_x<=max(electrode_travel));
displacement_probe = interp1(electrode_travel,displacement,valid_probe_x);

axes(h(1)),plot(electrode_travel,displacement,'+')
ylabel(['retinotopic displace' char(176)])
xlabel('electrode travel (mm)')
set(gca,'ylim',[0 20])
legend('220510','220511')

axes(h(2)),plot(T.X -Fix(1),T.Y-Fix(2),'-+')

x =2.0:3/30:5;
x = x-Fix(1);
y = -3.5:3/30:-.5;
b2.x = [x fliplr(x)];
b2.y=[-3.5*ones(1,length(x)) -.5*ones(1,length(x))];
axes(h(3)),plot(displacement_probe) 

%% 220513 , pen = e,4

filename= 'C:\Henry\Projects\Pulvinar\Cylinder\Chunky\chunky lgn mapping.xlsx';
opts = spreadsheetImportOptions;
opts.Sheet = '220513';
opts.VariableNames = [{'X'},{'Y'},{'Z'}];
opts.DataRange = 'a3:c29';
opts.VariableTypes =  {'double','double','double'} ;

T = readtable(filename,opts);

electrode_travel = T.Z - min(T.Z);
displacement = sqrt((T.X-T.X(1)).^2+ (T.Y-T.Y(1)).^2);

valid_probe_x = probe_x(probe_x<=max(electrode_travel));
displacement_probe = interp1(electrode_travel,displacement,valid_probe_x);

axes(h(1)),plot(electrode_travel,displacement,'p')
ylabel(['retinotopic displace' char(176)])
xlabel('electrode travel (mm)')
set(gca,'ylim',[0 20])
legend('220510','220511','220513')

axes(h(2)),plot(T.X -Fix(1),T.Y-Fix(2),'-+')

x =4:3/30:7;
x = x-Fix(1);
y = -3.5:3/30:-.5;

b3.x = [x fliplr(x)];
b3.y=[-1.5*ones(1,length(x)) 1.5*ones(1,length(x))];




fill(b3.x,b3.y,'k','FaceAlpha',.2,'EdgeAlpha',0)
fill(b2.x,b2.y,'k','FaceAlpha',.2,'EdgeAlpha',0)
legend('220510','220511','220513')
axes(h(3)),plot(displacement_probe) 

plot(1:128,3*ones(1,128),'--k')
plot(1:128,2*ones(1,128),'--k')
legend('220510','220511','220513')