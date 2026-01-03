/*

====================================================================
Bulk Insert to load the data into the table.
====================================================================
*/

TRUNCATE TABLE nfd.netflix
BULK INSERT nfd.netflix
  -- Here, the file location will be different for you. Select the file > right click > properties > security > copy the whole object name.
FROM 'C:\Users\iamta\Downloads\netflix.csv'
WITH(
FORMAT = 'CSV',
FIRSTROW = 2,
FIELDQUOTE = '"',
FIELDTERMINATOR = ',',
ROWTERMINATOR = '0x0a',
TABLOCK
);
