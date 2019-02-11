#Setup new Dev SQL management server using dsc

Configuration SQLAGGDBCluster
{

    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [Int]
        $DataDiskID,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [Int]
        $LogDiskID,
        [Parameter()]
        [Int]
        $TempDBDiskID,
        [Parameter()]
        [Int]
        $BackupDiskID,
        [parameter()]
        [String]
        $tempDB = 'E:\MSSQL\DATA',
        [parameter()]
        [String]
        $backup = 'E:\MSSQL',
        [parameter(Mandatory=$true)]
        [String]
        $PrimaryReplicaName
        

    )

    Import-DscResource -ModuleName SQLCompositeResources
    Import-DscResource -ModuleName StorageDSC -ModuleVersion 4.4.0.0

    $cred = Get-Credential -Message 'SQL Server Installation Account' -UserName 'bne_air1\sqladm'
    $ServiceAcct = $cred
    $AgtServiceAcct = $cred

    #Since D app is standard disk , make sure this disk is used as the sql binaries location rathe than C drive

    #Setup the primary Node

    
    Node DPVC01DBMGT01
    {
        
        $depnds = @("[Disk]DataDrive","[Disk]LogDrive")
           
        WaitForDisk DataDisk
        {
            DiskId = $DataDiskID
            RetryIntervalSec = 10
            RetryCount = 6
        }

        Disk DataDrive
        {
            DiskId = $DataDiskID
            DriveLetter = 'E'
            FSLabel = 'SQL Data'
            PartitionStyle = 'MBR'
            AllocationUnitSize = 64KB
            AllowDestructive = $true
            DependsOn = '[WaitForDisk]DataDisk'
        }

        WaitForDisk LogDisk
        {
            DiskId = $LogDiskID
            RetryIntervalSec = 10
            RetryCount = 6
        }

        Disk LogDrive
        {
            DiskId = $LogDiskID
            DriveLetter = 'F'
            FSLabel = 'SQL Log'
            PartitionStyle = 'MBR'
            AllocationUnitSize = 64KB
            AllowDestructive = $true
            DependsOn = '[WaitForDisk]LogDisk'
        }

        if($TempDBDiskID)
        {
            WaitForDisk TempDBDisk
            {
                DiskId = $LogDiskID
                RetryIntervalSec = 10
                RetryCount = 6
            }

            Disk TempDBDrive
            {
                DiskId              = $TempDBDiskID
                DriveLetter         = 'G'
                FSLabel             = 'SQL Temp DB'
                PartitionStyle      = 'MBR' 
                AllocationUnitSize  = 64KB
                AllowDestructive = $true
                DependsOn = '[WaitForDisk]TempDBDisk' 
            }

            $tempDB = 'G:\MSSQL\TempDB'

            File Tempdrive
            {
                DestinationPath = $tempDB
                Ensure = 'Present'
                Type = 'Directory'
                DependsOn = '[Disk]TempDBDrive'
            }

            $depnds+="[Disk]TempDBDrive"

        }

        if($BackupDiskID)
        {
            WaitForDisk BackupDisk
            {
                DiskId = $LogDiskID
                RetryIntervalSec = 10
                RetryCount = 6
            }

            Disk BackupDrive
            {
                DiskId              = $BackupDiskID
                DriveLetter         = 'H'
                FSLabel             = 'SQL Backups'
                PartitionStyle = 'MBR'
                AllocationUnitSize  = 64KB
                AllowDestructive = $true
                DependsOn = '[WaitForDisk]BackupDrive' 
            }

            $backup = 'H:\MSSQL\Backups'

            File Backup
            {
                DestinationPath = $backup
                Ensure = 'Present'
                Type = 'Directory'
                DependsOn = '[Disk]BackupDrive'
            }

            $depnds+="[Disk]BackupDrive"
        }
        
        
        File Ddrive
        {
            DestinationPath = 'D:\MSSQL'
            Type = 'Directory'
            Ensure = 'Present'
        }

        File DdriveWOW
        {
            DestinationPath = 'D:\MSSQL\WOW'
            Type = 'Directory'
            Ensure = 'Present'
        }
      
        File Edrive
        {
            DestinationPath = 'E:\MSSQL\DATA'
            Ensure = 'Present'
            Type = 'Directory'
            DependsOn = '[Disk]DataDrive'
        }

        File Fdrive
        {
            DestinationPath = 'F:\MSSQL\LOG'
            Ensure = 'Present'
            Type = 'Directory'
            DependsOn = '[Disk]LogDrive'
        } 

        <#Package InstallSSMS
        {
            Ensure = 'Present'
            Path = 'D:\SSMS\SSMS-Setup-ENU.exe'
            Name = 'Microsoft SQL Server Management Studio - 17.9'
            ProductId = '083356d9-896b-43ce-8013-f8e1e95c163d'
            Arguments = '/install /quite /norestart'
        }#>

        PrimaryAlwaysOn PrimaryNode
        {
            Server                      = 'localhost'
            ClusterName                 = 'DPVC01DBMGT'
            ClusterIP                   = '10.150.142.182'
            SetupSourcePath             = 'D:\SQLBinaries'
            Features                    = 'SQLEngine,Replication,BC,Conn,SDK'
            InstallSharedDir            = 'D:\MSSQL'
            InstallSharedWOWDir         = 'D:\MSSQL\WOW'
            InstanceDir                 = 'D:\MSSQL'
            InstallSQLDataDir           = 'E:\MSSQL\DATA'
            SQLUserDBDir                = 'E:\MSSQL\DATA'
            SQLUserDBLogDir             = 'F:\MSSQL\LOG'
            SQLTempDBDir                = $tempDB
            SQLTempDBLogDir             = $tempDB
            SQLBackupDir                = $backup
            SqlInstallCredential        = $cred
            SqlServiceCredential        = $ServiceAcct
            SqlAgentServiceCredential   = $AgtServiceAcct
            SQLSysAdminAccounts         = @("bne_air1\nweerasinghe_admin")

            DependsOn                   = $depnds 
        }
        AvailabilityGroup DONEIN30MINUTES
        {
            Server = 'localhost'
            SqlInstallCredential = $cred
            AvailabilityGroupName = 'DONEIN30MINUTES'
            DependsOn           = '[PrimaryAlwaysOn]PrimaryNode'
        }
    }
}

[DscLocalConfigurationManager()]
Configuration LCMPush
{
    Node localhost
    {
        Settings
        {
            ActionafterReboot = 'ContinueConfiguration'
            AllowModuleOverwrite = $true
            ConfigurationMode = 'ApplyAndAutoCorrect'
            ConfigurationModeFrequencyMins = 15
            RefreshFrequencyMins = 30
            StatusRetentionTimeInDays = 7
            RebootNodeIfNeeded = $true
            RefreshMode = 'Push'
        }
    }
}

$cd = @{
        AllNodes = @(
             @{
                NodeName = 'DPVC01DBMGT01'
                PSDScAllowDomainUser = $true
                PSDScAllowPlainTextPassword = $true
              }
             @{
                NodeName = 'DPVC01DBMGT02'
                PSDScAllowDomainUser = $true
                PSDScAllowPlainTextPassword = $true
              })
        }


LCMPush
SQLAGGDBCluster -PrimaryReplicaName 'DPVC01DBMGT01' -DataDiskID 2 -LogDiskID 3 -TempDBDiskID 4  -ConfigurationData $cd -Verbose