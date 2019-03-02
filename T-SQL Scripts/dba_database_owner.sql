SELECT 
    name AS [Database],
    SUSER_SNAME(owner_sid) AS [owner] 
FROM sys.databases

--SELECT 
--    A.name AS [databse name],
--   B.name AS [Owner] 
--FROM sys.databases A
--JOIN sys.server_principals B ON A.owner_sid = B.sid