WITH Details(Device_Name,Device_Type,Device_Model,Device_Primary_Hostname,Device_Placement_Name,DeviceDetailsXml)
AS (
		SELECT 
			DS.name AS Device_Name,
			DS.type AS Device_Type,
			DS.device_model AS Device_Model,
			S.hostname AS Device_Primary_Hostname,
			G.name AS Device_Placement_Name,
			CAST(REPLACE(DS.xml_config,'UTF-8','UTF-16') AS XML) AS DeviceDetailsXml
		FROM [xovis].[dbo].[devices] AS DS
		JOIN dbo.servers S ON S.server_id = DS.server_id
		JOIN dbo.devices_in_groups DG ON DG.device_id = DS.id
		JOIN dbo.groups G ON G.id = DG.group_id
    )
SELECT 
	Device_Name,
	Device_Type,
	Device_Model,
	Device_Primary_Hostname,
	Device_Placement_Name,
	dXml.r.value('(IPAddress)[1]','nvarchar(max)') AS IpAddress,
	dXml.r.value('(Netmask)[1]','nvarchar(max)') AS Netmask,
	dXml.r.value('(Gateway)[1]','nvarchar(max)') AS Gateway,
	dXml.r.value('(DNS)[1]','nvarchar(max)') AS DNS
FROM Details
	CROSS APPLY DeviceDetailsXml.nodes('//settings//Network') dXml(r)

