--This script list all index fragmentations as found in Redgate SQL Monitor Database and creates 
--ALTER INDEX commands based on fragmentation level. 

USE [Redgatemonitor-New] --change db name to match sqlmon db_name 
SELECT 
    'ALTER INDEX ' + B._Name + 'ON' + ' ' + 
    CASE E._Name WHEN '' THEN F._Name ELSE E._Name END + 
    '.' + D._Name + '.' + C._Schema + '.' + C._Name +
    CASE  WHEN A._Fragmentation > 0.3 THEN 'REORGANIZE' ELSE 'REBUILD' END
   
FROM [data].[Cluster_SqlServer_Database_Table_Index_UnstableSamples] A
JOIN [data].[Cluster_SqlServer_Database_Table_Index_Keys] B ON B.Id = A.Id
JOIN [data].[Cluster_SqlServer_Database_Table_Keys] C ON C.Id = B.ParentId
JOIN [data].[Cluster_SqlServer_Database_Keys] D ON D.Id = C.ParentId
JOIN [data].[Cluster_SqlServer_Keys] E ON E.Id = D.ParentId
JOIN [data].[Cluster_Keys] F ON F.id = E.ParentId	
--WHERE a._Fragmentation > 0.8 AND D._Name like 'Red%' 
ORDER BY Fragmentation DESC