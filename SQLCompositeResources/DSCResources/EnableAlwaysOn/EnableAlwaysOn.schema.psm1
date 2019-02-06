Configuration EnableAlwaysOn {
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
        
        [ValidateNotNullorEmpty()]
        [string]
        $HADRPort =5022,
        
        [ValidateNotNullorEmpty()]
        [string]
        $RestartTimeout = 120
)

    Import-DscResource -ModuleName SQLServerDsc -ModuleVersion 12.2.0.0
    
    # Adding the required service account to allow the cluster to log into SQL
    SQLServerLogin AddNTServiceClusSvc
    {
        Ensure               = 'Present'
        Name                 = 'NT SERVICE\ClusSvc'
        LoginType            = 'WindowsUser'
        ServerName =         = $Server
        InstanceName         = $SQLInstance
        PsDscRunAsCredential = $SqlInstallCredential
    }

    # Add the required permissions to the cluster service login
    SQLServerPermission AddNTServiceClusSvcPermissions
    {
        DependsOn            = '[xSQLServerLogin]AddNTServiceClusSvc'
        Ensure               = 'Present'
        ServerName           = $Server
        InstanceName         = $SQLInstance
        Principal            = 'NT SERVICE\ClusSvc'
        Permission           = 'AlterAnyAvailabilityGroup', 'ViewServerState'
        PsDscRunAsCredential = $SqlInstallCredential
    }

    # Create a DatabaseMirroring endpoint
    SQLServerEndpoint HADREndpoint
    {
        EndPointName         = 'HADR'
        Ensure               = 'Present'
        Port                 = $HADRPort
        ServerName           = $Server
        InstanceName      = $SQLInstance
        PsDscRunAsCredential = $SqlInstallCredential
    }
    
    SQLServerLogin AddSQLServiceAccount
    {
        Ensure               = 'Present'
        Name                 = $SqlServiceCredential.UserName
        LoginType            = 'WindowsUser'
        ServerName            = $Server
        InstanceName      = $SQLInstance
        PsDscRunAsCredential = $SqlInstallCredential
    }

    SQLServerEndpointPermission SQLConfigureEndpointPermission
    {
        Ensure               = 'Present'
        ServerName             = $Server
        InstanceName         = $SQLInstance
        Name                 = 'HADR'
        Principal            = $SqlServiceCredential.UserName
        Permission           = 'CONNECT'
    
        PsDscRunAsCredential = $SqlInstallCredential
        DependsOn = '[xSQLServerEndpoint]HADREndpoint','[xSQLServerLogin]AddSQLServiceAccount'
    }
    
    SQLAlwaysOnService 'EnableAlwaysOn'
    {
        Ensure               = 'Present'
        ServerName           = $Server
        InstanceName            = $SQLInstance
        RestartTimeout       = $RestartTimeout

        PsDscRunAsCredential = $SqlInstallCredential
    }


}