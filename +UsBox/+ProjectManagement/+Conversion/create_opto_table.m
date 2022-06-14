function [opto_table] = create_opto_table(excel_table)



opto_table = table(excel_table.FileID,excel_table.OptoRating, excel_table.Opsin, excel_table.FiberLocation,excel_table.FiberRF,...
            excel_table.LaserColor, excel_table.LaserLevel);
        opto_table.Properties.VariableNames = {'FileID', 'OptoRating', 'Opsin', 'FiberLocation', 'FiberRF',...
            'LaserColor','LaserLevel'};