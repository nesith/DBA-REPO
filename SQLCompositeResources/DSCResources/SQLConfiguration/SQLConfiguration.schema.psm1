Configuration SQLConfiguration {
Param(  [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $Server,

        [ValidateNotNullorEmpty()]
        [string]
        $SQLInstance = 'MSSQLSERVER',
        
        [ValidateNotNullorEmpty()]
        [string]
        $SQLPort = '1433',
        
        [ValidateNotNullorEmpty()]
        [string]
        $VirtualMemoryInitialSize = 4096,
        
        [ValidateNotNullorEmpty()]
        [string]
        $VirtualMemoryMaximumSize = 4096,
        
        [ValidateNotNullorEmpty()]
        [string]
        $VirtualMemoryDrive = 'C',
        
        [ValidateNotNullorEmpty()]
        [string]
        $XpCmdShellEnabled = 0,

        [ValidateNotNullorEmpty()]
        [string]
        $OptimizeAdhocWorkloads = 0,

        [ValidateNotNullorEmpty()]
        [string]
        $CrossDBOwnershipChaining = 0,

        [ValidateNotNullorEmpty()]
        [string]
        $IsSqlClrEnabled = 0,
        
        [ValidateNotNullorEmpty()]
        [string]
        $AgentXPsEnabled = 1,

        [ValidateNotNullorEmpty()]
        [string]
        $DatabaseMailEnabled = 0,

        [ValidateNotNullorEmpty()]
        [string]
        $OleAutomationProceduresEnabled = 0,
        
        [ValidateNotNullorEmpty()]
        [string]
        $DefaultBackupCompression = 1,

        [ValidateNotNullorEmpty()]
        [string]
        $RemoteDacConnectionsEnabled = 0,

        [ValidateNotNullorEmpty()]
        [string]
        $AdHocDistributedQueriesEnabled = 0
        )

    Import-DscResource -ModuleName SQLServerDsc -ModuleVersion 12.2.0.0
    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 6.1.0.0 
    Import-DscResource -ModuleName StorageDsc -ModuleVersion 4.4.0.0
    Import-DscResource -ModuleName NetworkingDsc -ModuleVersion 6.3.0.0
    Import-DscResource -ModuleName SecurityPolicyDsc -ModuleVersion 2.7.0.0
    
    PowerPlan SetPlanHighPerformance
    {
        IsSingleInstance = 'yes'
        Name             = "High Performance"
    }

    <#VirtualMemory SetVirtualMem
    {
         Drive          = $VirtualMemoryDrive
         Type           = 'CustomSize'
         InitialSize    = $VirtualMemoryInitialSize
         MaximumSize    = $VirtualMemoryMaximumSize
    }#>
    SQLServerMemory 'SetSQLMemory'
    {
        InstanceName             = $SQLInstance
        DynamicAlloc             = $true
        Ensure                   = 'Present'
        MinMemory                = 1024 
        ProcessOnlyOnActiveNode  = $true
    }

    SQLServerMaxDop 'SetMaxXop'
    {
        InstanceName             = $SQLInstance
        DynamicAlloc             = $true
        Ensure                   = 'Present'
        ProcessOnlyOnActiveNode  = $true
    }

    SQLServerNetwork 'ConfigNetwork'
    {
       InstanceName     = $SQLInstance
       ProtocolName     = 'TCP'
       IsEnabled        = $true
       TcpPort          = $SQLPort
       TcpDynamicPort   = $false 
       RestartService   = $true
    }

    SQLServerConfiguration 'XPCmdShellEnabled'
    {
        ServerName      = $Server
        InstanceName    = $SQLInstance
        OptionName      = "xp_cmdshell" 
        OptionValue     = $XpCmdShellEnabled
        RestartService  = $false
    }


    SQLServerConfiguration 'AgentXPsEnabled'
    {
        ServerName      = $Server
        InstanceName    = $SQLInstance
        OptionName      = "Agent XPs" 
        OptionValue     = $AgentXPsEnabled
        RestartService  = $false
    }

    SQLServerConfiguration 'DatabaseMailEnabled'
    {
        ServerName      = $Server
        InstanceName    = $SQLInstance
        OptionName      = "Database Mail XPs" 
        OptionValue     = $DatabaseMailEnabled
        RestartService  = $false
    }

    SQLServerConfiguration 'OptimizeAdhocWorkloads' 
    {
        ServerName      = $Server
        InstanceName    = $SQLInstance
        OptionName      = "optimize for ad hoc workloads" 
        OptionValue     = $OptimizeAdhocWorkloads
        RestartService  = $false
    }

    SQLServerConfiguration 'CrossDBOwnershipChaining'
    {
        ServerName      = $Server
        InstanceName    = $SQLInstance
        OptionName      = "cross db ownership chaining" 
        OptionValue     = $CrossDBOwnershipChaining
        RestartService  = $false
    }

    SQLServerConfiguration 'IsSqlClrEnabled'
    {
        ServerName      = $Server
        InstanceName    = $SQLInstance
        OptionName      = "clr enabled" 
        OptionValue     = $IsSqlClrEnabled
        RestartService  = $false
    }

    SQLServerConfiguration 'OleAutomationProceduresEnabled'
    {
        ServerName      = $Server
        InstanceName    = $SQLInstance
        OptionName      = "Ole Automation Procedures" 
        OptionValue     = $OleAutomationProceduresEnabled
        RestartService  = $false
    }

    SQLServerConfiguration 'DefaultBackupCompression'
    {
        ServerName      = $Server
        InstanceName    = $SQLInstance
        OptionName      = "backup compression default" 
        OptionValue     = $DefaultBackupCompression
        RestartService  = $false
    }

    SQLServerConfiguration 'RemoteDacConnectionsEnabled'
    {
        ServerName      = $Server
        InstanceName    = $SQLInstance
        OptionName      = "remote admin connections" 
        OptionValue     = $RemoteDacConnectionsEnabled
        RestartService  = $false
    }

    SQLServerConfiguration 'AdHocDistributedQueriesEnabled'
    {
        ServerName      = $Server
        InstanceName    = $SQLInstance
        OptionName      = "Ad Hoc Distributed Queries" 
        OptionValue     = $AdHocDistributedQueriesEnabled
        RestartService  = $false
    }

    SqlServerConfiguration 'FillFactor'
    {
        ServerName = $Server
        InstanceName = $SQLInstance
        OptionName = 'fill factor (%)'
        OptionValue = 100
    }

    SqlServerConfiguration 'CostThresholdofParallelism'
    {
        ServerName = $Server
        InstanceName = $SQLInstance
        OptionName = 'cost threshold for parallelism'
        OptionValue = 50
    }

    UserRightsAssignment InstantFilieIni
    {
        Policy     = 'Perform_volume_maintenance_tasks' 
        Identity   = $SQLServiceAccount        
    }

    FirewallProfile PrivateProfile
    {
        Name    = 'Private'
        Enabled = 'False' 
    }

    FirewallProfile DomainProfile
    {
        Name    = 'Domain'
        Enabled = 'False' 
    }
    
    FirewallProfile PublicProfile
    {
        Name    = 'Public'
        Enabled = 'False' 
    }

    
}