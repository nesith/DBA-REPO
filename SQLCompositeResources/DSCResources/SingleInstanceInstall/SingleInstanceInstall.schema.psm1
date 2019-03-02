Configuration SingleInstanceInstall {
    param
    (
        [Parameter()]
        [ValidateNotNullorEmpty()]
        [ValidateSet('Install')]
        [string]
        $Action = 'Install',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $Server,

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $SQLInstance = 'MSSQLSERVER',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $SetupSourcePath,
        
        [Parameter()]
        [ValidateNotNullorEmpty()]
        [bool]
        $UpdateEnabled = $False,
        
        [Parameter()]
        [ValidateNotNullorEmpty()]
        [bool]
        $ForceReboot = $False,
        
        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $Features ='SQLENGINE',
        
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string[]]
        $SQLSysAdminAccounts,

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $SQLCollation ='SQL_Latin1_General_CP1_CI_AS',

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $InstallSharedDir = 'C:\Program Files\Microsoft SQL Server',

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $InstallSharedWOWDir = 'C:\Program Files (x86)\Microsoft SQL Server',

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $InstanceDir ='C:\Program Files\Microsoft SQL Server',

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $InstallSQLDataDir = 'C:\Program Files\Microsoft SQL Server\MSSQL.MSSQLSERVER\MSSQL\Data',

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $SQLUserDBDir = 'C:\Program Files\Microsoft SQL Server\MSSQL.MSSQLSERVER\MSSQL\Data',

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $SQLUserDBLogDir = 'C:\Program Files\Microsoft SQL Server\MSSQL.MSSQLSERVER\MSSQL\Data',

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $SQLTempDBDir = 'C:\Program Files\Microsoft SQL Server\MSSQL.MSSQLSERVER\MSSQL\Data',

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $SQLTempDBLogDir = 'C:\Program Files\Microsoft SQL Server\MSSQL.MSSQLSERVER\MSSQL\Data',

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $SQLBackupDir = 'C:\Program Files\Microsoft SQL Server\MSSQL.MSSQLSERVER\MSSQL\Backup',
        
        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $SQLPort = '1433',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SqlInstallCredential,

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SqlAdministratorCredential = $SqlInstallCredential,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SqlServiceCredential,

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SqlAgentServiceCredential = $SqlServiceCredential,

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $VirtualMemoryInitialSize = 4096,
        
        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $VirtualMemoryMaximumSize = 4096,
        
        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $VirtualMemoryDrive = 'C',
        
        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $XpCmdShellEnabled = 0,

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $OptimizeAdhocWorkloads = 0,

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $CrossDBOwnershipChaining = 0,

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $IsSqlClrEnabled = 0,
        
        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $AgentXPsEnabled = 1,

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $DatabaseMailEnabled = 0,

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $OleAutomationProceduresEnabled = 0,
        
        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $DefaultBackupCompression = 1,

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $RemoteDacConnectionsEnabled = 0,

        [Parameter()]
        [ValidateNotNullorEmpty()]
        [string]
        $AdHocDistributedQueriesEnabled = 0
    )
    
    Import-DscResource -ModuleName PSDScresources -ModuleVersion 2.9.0.0
    Import-DscResource -ModuleName SQLServerDsc -ModuleVersion 12.3.0.0
    Import-DscResource -ModuleName SQLCompositeResources -ModuleVersion 2.0
    
    WindowsFeature 'NetFramework45'
    {
        Name   = 'NET-Framework-45-Core'
        Ensure = 'Present'
    }
    
    SqlSetup 'SQLInstall'
    {
        Action                  = $Action
        InstanceName            = $SQLInstance
        SourcePath              = $SetupSourcePath
        Features                = $Features
        UpdateEnabled           = $UpdateEnabled
        InstallSharedDir        = $InstallSharedDir
        InstallSharedWOWDir     = $InstallSharedWOWDir
        InstanceDir             = $InstanceDir
        SQLSvcAccount           = $SqlServiceCredential
        AgtSvcAccount           = $SqlAgentServiceCredential
        SQLCollation            = $SQLCollation
        SQLSysAdminAccounts     = $SQLSysAdminAccounts
        InstallSQLDataDir       = $InstallSQLDataDir 
        SQLUserDBDir            = $SQLUserDBDir
        SQLUserDBLogDir         = $SQLUserDBLogDir
        SQLTempDBDir            = $SQLTempDBDir
        SQLTempDBLogDir         = $SQLTempDBLogDir
        SQLBackupDir            = $SQLBackupDir
        ForceReboot             = $ForceReboot       
        
        PsDscRunAsCredential    = $SqlInstallCredential

        DependsOn               = '[WindowsFeature]NetFramework45'
    }

    SqlConfiguration 'ConfigureSQLInstall'
    {
        Server                          = $Server
        SQLInstance                     = $SQLInstance
        SQLPort                         = $SQLPort
        VirtualMemoryInitialSize        = $VirtualMemoryInitialSize
        VirtualMemoryMaximumSize        = $VirtualMemoryMaximumSize
        VirtualMemoryDrive              = $VirtualMemoryDrive
        XpCmdShellEnabled               = $XpCmdShellEnabled
        OptimizeAdhocWorkloads          = $OptimizeAdhocWorkloads
        CrossDBOwnershipChaining        = $CrossDBOwnershipChaining
        IsSqlClrEnabled                 = $IsSqlClrEnabled
        AgentXPsEnabled                 = $AgentXPsEnabled
        DatabaseMailEnabled             = $DatabaseMailEnabled
        OleAutomationProceduresEnabled  = $OleAutomationProceduresEnabled
        DefaultBackupCompression        = $DefaultBackupCompression
        RemoteDacConnectionsEnabled     = $RemoteDacConnectionsEnabled
        AdHocDistributedQueriesEnabled  = $AdHocDistributedQueriesEnabled
    
        DependsOn                       = '[SqlSetup]SQLInstall'
    }


}