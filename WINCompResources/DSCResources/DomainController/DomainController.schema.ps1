#This file contains the definition of a domain controller which can be created through DSC.
#Since this is a composite resource, this can be used in any DSC config file after importing it.

Configuration DomainController
{
    Param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [string]
        $DomainName,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $DomainAdminCred,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SafeModeAdminCred
    )
    Import-DscResource -ModuleName xActiveDirectory -ModuleVersion 2.23.0.0

    xADDomain PrimaryDC
    {
        DomainName                      = $DomainName
        DomainAdministratorCredential   = $DomainAdminCred
        SafemodeAdministratorPassword   = $SafeModeAdminCred 
    }

}