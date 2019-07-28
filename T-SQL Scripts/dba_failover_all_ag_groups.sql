DECLARE @sql NVARCHAR(max);

SET @sql = ''

SELECT @sql = 'ALTER AVAILABILITY GROUP ' + NAME + ' FAILOVER;'+ @sql FROM SYS.availability_groups 

EXECUTE @sql
