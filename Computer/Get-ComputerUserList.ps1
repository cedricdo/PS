function Get-ComputerUserList
{
    <#

    .SYNOPSIS
        Get the users of a specific domain which logged on a host

    .DESCRIPTION
        Get the users of a specific domain which logged on a host

    .PARAMETER ComputerName
        The name of the ost

    .PARAMETER DomainName
        The domain name

    .PARAMETER DomainSid
        The domain SID

    .PARAMETER ExcludedAccounts
        List of users which will be excluded from the result

    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,
        [Parameter(Mandatory=$true)]
        [string]$DomainName,
        [Parameter(Mandatory=$true)]
        [string]$DomainSid,
        [string[]]$ExcludedAccounts = @(),
        [switch]$NoProgess
    )

    $listUser = @()
    
    $users = Get-RegKey -ComputerName $ComputerName -Key "SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
    if($ExcludedAccounts.Count -gt 0)
    {
        $ExcludedAccounts = $ExcludedAccounts | % {
                                $objUser = New-Object System.Security.Principal.NTAccount($DomainName, $_)
                                $objUser.Translate([System.Security.Principal.SecurityIdentifier]).Value
                            }
    }

    $count = 0
    foreach($user in $users)
    {
        $count++
        if(!$NoProgess)
        {
            Write-Progress -Activity "Analyse users" `
                           -Status "Analyse $count off $($users.Count)" `
                           -PercentComplete ($count / $users.Count * 100)
        }
        $sid = $user.key.Substring($user.Key.LastIndexOf("\")+1)
        if((-not $ExcludedAccounts.Contains($sid)) -and $sid.StartsWith($DomainSid))
        {
            $objSID = New-Object System.Security.Principal.SecurityIdentifier($sid)
            $listUser += [pscustomobject]@{
                Host = $computerName
                Sid = $objSID
                Name = $objSID.Translate([System.Security.Principal.NTAccount])
            }
            $objUser = $objSID.Translate([System.Security.Principal.NTAccount])
        }
    }

    $listUser
}