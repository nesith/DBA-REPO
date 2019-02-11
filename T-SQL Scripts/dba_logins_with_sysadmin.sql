--Find logins which have been granted sysadmin
SELECT sp2.name AS [login name],sp1.name AS [role name] FROM sys.server_principals sp1 
JOIN sys.server_role_members srm ON srm.role_principal_id = sp1.principal_id
RIGHT JOIN sys.server_principals sp2 ON sp2.principal_id = srm.member_principal_id
WHERE sp2.type <> 'R' AND sp2.type <>'C' AND sp2.name NOT LIKE '##%' AND sp2.name <> 'sa' AND sp1.name = 'sysadmin'