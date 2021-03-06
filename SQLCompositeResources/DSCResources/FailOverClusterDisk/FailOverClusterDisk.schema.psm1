Configuration FailOverClusterDisk {
Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [hashtable[]]
        $DiskConfiguration
)
Import-DscResource -ModuleName StorageDsc -ModuleVersion 4.4.0.0
Import-DscResource -ModuleName xFailoverCluster -ModuleVersion 1.12.0.0

    foreach ($Disk in $DiskConfiguration)
    {
        xClusterDisk $Disk.Label
        {
            Number = $Disk.Number
            Ensure = 'Present'
            Label  = $Disk.Label

            DependsOn = "[xDisk]$($Disk.Label)"
        }
        
    
        xWaitforDisk $Disk.Label
        {
             DiskId = $Disk.Number
             RetryIntervalSec = $Disk.RetryInterval
             RetryCount = $Disk.RetryCount

             DependsOn = "[xDisk]$($Disk.Label)"
        }
    
        xDisk $Disk.Label
        {
             DiskId = $Disk.Number
             DriveLetter = $Disk.Letter
             FSFormat = $Disk.Format
             AllocationUnitSize = 64KB
        }
    }
}