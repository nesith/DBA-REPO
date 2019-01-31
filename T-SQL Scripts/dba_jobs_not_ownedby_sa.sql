--This Script Shows agent jobs which are not owned by SA
SELECT 
	A.name AS [Job Name],
	B.name AS [Job Owner Name],
	CASE A.enabled WHEN 0 THEN	'Disabled' ELSE 'Enabled' END AS [Job Status] 
FROM msdb.dbo.sysjobs A
JOIN master.sys.server_principals B ON A.owner_sid = B.sid
WHERE B.name <> 'sa'

