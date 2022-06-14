function plot_pen_retinotopy(file_name,sheet,data_range)


opts = spreadsheetImportOptions;
opts.Sheet = sheet;
opts.VariableNames = [{'X'},{'Y'},{'Z'}];
opts.DataRange = data_range;
opts.VariableTypes =  {'double','double','double'} ;

T = readtable(file_name,opts);

electrode_travel = T.Z - min(T.Z);
displacement = sqrt((T.X-T.X(1)).^2+ (T.Y-T.Y(1)).^2);
figure(1),plot(electrode_travel,displacement,'o')
ylabel(['retinotopic displace' char(176)])
xlabel('electrode travel (mm)')
set(gca,'ylim',[0 20])