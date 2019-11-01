#Script which builds Availability group(s)

#requires -version 5.0
#requires -modules sqlserver

$AgName = ''
$Replicas = ('','','')
$DbName = ''

$newAG = New-SqlAvailabilityGroup -Name $AgName -AvailabilityReplica $Replicas `
 -AutomatedBackupPreference Primary -DatabaseHealthTrigger -ClusterType Wsfc -Database $DbName