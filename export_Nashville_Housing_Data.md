
1)Relance SSMS en administrateur
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;



GO
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1;
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1;
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.16.0', N'AllowInProcess', 1;
EXEC sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.16.0', N'DynamicParameters', 1;
GO
  

SELECT * INTO DataCleaning FROM OPENROWSET('Microsoft.ACE.OLEDB.16.0', 'Excel 12.0;Database=C:\Users\maria\Desktop\Nashville_Housing_Data.xlsx;HDR=YES', 'SELECT * FROM [Sheet1$]');


SELECT TOP 10 * FROM DataCleaning;
