SELECT 
	db_name(database_id) AS [Database Name],
	CASE
		WHEN sum(size * 8)/1024/1024/1024 >= 1 THEN convert(varchar(max),(convert(decimal(10,2),(convert(decimal(10,2),convert(decimal(10,2),(sum(size *8)/1024))/1024))/1024))) + ' (TB)'
		WHEN sum(size * 8)/1024/1024 >= 1 THEN convert(varchar(max),(convert(decimal(10,2),convert(decimal(10,2),(sum(size *8)/1024))/1024))) + ' (GB)' 
		WHEN sum(size * 8)/1024 >= 1 THEN convert(varchar(max),(convert(decimal(10,2),(sum(size *8)/1024)))) + ' (MB)'
		ELSE convert(varchar(max),sum(size * 8))  + ' (KB)'
	END AS [Database Size]
FROM sys.master_files GROUP BY database_id