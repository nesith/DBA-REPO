#This function uses dbatools to refresh MRI database BACTEST, with error checking and extra validations.

#Assumption is that refresh happens on the first day of the month. if it's requested outside of the first day of the month do other
#Checks and ask for validation

#requires -Modules dbatools
#requires -Version 5.0

param 
(
    [parameter(Mandatory=$true)]
    [String] 
    $ServerName,
    [String]
    $InstanceName = 'MSSQLSERVER',
    [Int]
    $Port = 1433,
    [Parameter(Mandatory=$true)]
    [String]
    $DatabaseName
     
)

if($InstanceName -ne 'MSSQLSERVER')
{
    $instance = $ServerName + '\' + $InstanceName
}
else 
{
    $instance = $ServerName   
}


#Rename the current BACTEST database with previous month postfixed to the name

Rename-DbaDatabase -SqlInstance $instance -Database $DatabaseName