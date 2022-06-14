username = 'root';
password = "&7ccV%9h6!+)GVR-68nyNMRN";

test_database = databaseConnectionOptions("jdbc","MySQL");

test_database = setoptions(test_database,'DataSourceName', 'test_data',...
    'JDBCDriverLocation','C:\Program Files (x86)\MySQL\Connector J 8.0\mysql-connector-java-8.0.25.jar',...
    'DatabaseName','learning');

status = testConnection(test_database,username,password)

saveAsDataSource(test_database)

conn = database('test_data',username,password)


%%
%to reload connection
%use the 'DataSourceName' = 'test_data'


%opts = databaseConnectionOptions('test_data')

%%