Configuration Test
{
    Import-DscResource -ModuleName SqlServerDsc -ModuleVersion 12.2.0.0

    $cred = Get-Credential -Message 'SQL Server Installation Account' -UserName 'bne_air1\sqladm'

    Node DPVC01DBMGT01
    {
        SqlSetup InstallSQL2017
        {
            InstanceName        = 'MSSQLSERVER'
            SourcePath          = 'D:\SQLBinaries'
            ForceReboot         = $false
            Features            = 'SQL,TOOLS'
            UpdateEnabled       = $false
            InstallSharedDir    = 'D:\MSSQL'
            InstallSharedWOWDir = 'D:\MSSQL\WOW'
            InstanceDir         = 'D:\MSSQL'
            InstallSQLDataDir   = 'E:\MSSQL\DATA'
            SQLUserDBDir        = 'E:\MSSQL\DATA'
            SQLUserDBLogDir     = 'F:\MSSQL\LOG'
            SQLTempDBDir        = 'G:\MSSQL\TempDB'
            SQLTempDBLogDir     = 'G:\MSSQL\TempDB'
            SQLBackupDir        = 'E:\MSSQL'
            SQLSvcAccount       = $cred
            AgtSvcAccount       = $cred
            SQLSysAdminAccounts = @("bne_air1\nweerasinghe_admin")

            PsDscRunAsCredential = $cred
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

Test -ConfigurationData $cd