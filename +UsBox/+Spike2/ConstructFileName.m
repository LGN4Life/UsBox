function file_name    = ConstructFileName(data_set,ExcelInput)


file_name = [data_set.MatlabDirectory  ExcelInput.FileName '_' num2str(ExcelInput.RecordingNumber) '.mat'];





