--This script list all index fragmentations as found in Redgate SQL Monitor Database 
USE [Redgatemonitor-New] --change db name to match sqlmon db_name 
SELECT 
    A._Fragmentation AS [Fragmentation],
    B._Name AS [Index Name],
    c._Schema AS [Schema],
    c._Name AS [Table Name],
    D._Name AS [Database Name],
    E._Name AS [Node],
    F._Name AS [Cluster/Server] 
FROM [data].[Cluster_SqlServer_Database_Table_Index_UnstableSamples] A
JOIN [data].[Cluster_SqlServer_Database_Table_Index_Keys] B ON B.Id = A.Id
JOIN [data].[Cluster_SqlServer_Database_Table_Keys] C ON C.Id = B.ParentId
JOIN [data].[Cluster_SqlServer_Database_Keys] D ON D.Id = C.ParentId
JOIN [data].[Cluster_SqlServer_Keys] E ON E.Id = D.ParentId
JOIN [data].[Cluster_Keys] F ON F.id = E.ParentId	
--WHERE a._Fragmentation > 0.8 AND D._Name like 'Red%' 
ORDER BY Fragmentation DESC