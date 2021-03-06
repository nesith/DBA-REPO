Configuration AvailabilityGroup {
Param(  
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $Server,
        
        [ValidateNotNullorEmpty()]
        [string]
        $SQLInstance = 'MSSQLSERVER',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SqlInstallCredential,
    
        [Parameter(Mandatory = $true)]    
        [ValidateNotNullorEmpty()]
        [String[]]
        $AvailabilityGroupName,
         
        [ValidateNotNullorEmpty()]
        [String]
        $AutomatedBackupPreference = 'Primary',
        
        [ValidateNotNullorEmpty()]
        [String]
        $AvailabilityMode = 'SynchronousCommit',

        [ValidateNotNullorEmpty()]
        [int16]
        $BackupPriority = 50,

        [ValidateNotNullorEmpty()]
        [String]
        $ConnectionModeInPrimaryRole= 'AllowAllConnections',

        [ValidateNotNullorEmpty()]
        [String]
        $ConnectionModeInSecondaryRole = 'AllowNoConnections',

        [ValidateNotNullorEmpty()]
        [String]
        $FailoverMode ='Automatic',

        [ValidateNotNullorEmpty()]
        [int16]
        $HealthCheckTimeout = 15000,

        [bool]
        $DatabaseHealthTrigger = $true,
        
        [bool]
        $DtcSupportEnabled = $true,

        [bool]
        $BasicAG = $false

        )

    Import-DscResource -ModuleName SQLServerDsc -ModuleVersion 12.3.0.0

    foreach ($AG in $AvailabilityGroupName)
    {
        SqlAG $AG
            {
                Ensure                        = 'Present'
                Name                          = $AG
                InstanceName                  = $SQLInstance
                ServerName                    = $Server
                
                AutomatedBackupPreference     = $AutomatedBackupPreference    
                AvailabilityMode              = $AvailabilityMode             
                BackupPriority                = $BackupPriority               
                ConnectionModeInPrimaryRole   = $ConnectionModeInPrimaryRole  
                ConnectionModeInSecondaryRole = $ConnectionModeInSecondaryRole
                FailoverMode                  = $FailoverMode                 
                HealthCheckTimeout            = $HealthCheckTimeout                   
                
                BasicAvailabilityGroup        = $BasicAG
                DatabaseHealthTrigger         = $DatabaseHealthTrigger
                DtcSupportEnabled             = $DtcSupportEnabled    
        
                PsDscRunAsCredential          = $SqlInstallCredential
            }
        }
    }
