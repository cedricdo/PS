function Get-ComputerLocalGroupMember
{
    <#

    .SYNOPSIS
        Get the list of users of a local group on a host

    .DESCRIPTION  
        Get the list of users of a local group on a host

    .PARAMETER ComputerName
       The name of the host

    .PARAMETER GroupName
        The name of the group. It depends on the host language

    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,
        [Parameter(Mandatory=$true)]
        [string]$GroupName
    )

    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    $ctype = [System.DirectoryServices.AccountManagement.ContextType]::Machine

    $context = New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext -ArgumentList $ctype, $computername
    $idtype  = [System.DirectoryServices.AccountManagement.IdentityType]::SamAccountName
    $group   = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($context, $idtype, $groupname)
    $group.Members | select @{N='Domain'; E={$_.Context.Name}}, @{N='Group'; E={$GroupName}}, samaccountName
}
