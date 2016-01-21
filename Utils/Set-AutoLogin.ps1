function Set-AutoLogin
{
    <#
    .SYNOPSIS
	    Define an autologin on a host

    .DESCRIPTION
	    Define an autologin on a host
	       
    .PARAMETER ComputerName
	    The host name

    .PARAMETER User
        The user name for autologin

    .PARAMETER Password
        The password for autologin

    .PARAMETER Domain
        The domain for autologin

    #>
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$ComputerName,
        [Parameter(Mandatory=$true)]
        [string]$User,
        [Parameter(Mandatory=$true)]
        [string]$Password,
        [Parameter(Mandatory=$true)]
        [string]$Domain,
        [switch]$NoProgress
    )

    $count = 0

    $ComputerName | % {
    
        $count++
        if(!$NoProgress)
        {
            Write-Progress -Activity "Set autologin" `
                           -Status "Working on $_" `
                           -PercentComplete ($count / $ComputerName.Count * 100)
        }
        If(!(Test-Connection -ComputerName $_ -Count 1 -Quiet))
        {
            Write-Warning "$_ is unreachable..." 
            return
        }

        $path   = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

        Set-RegString -ComputerName $_ -Hive "LocalMachine" -Key $path -Force -Value "AutoAdminLogon" -Data "1"
        Set-RegString -ComputerName $_ -Hive "LocalMachine" -Key $path -Force -Value "DefaultDomainName" -Data $Domain
        Set-RegString -ComputerName $_ -Hive "LocalMachine" -Key $path -Force -Value "DefaultUserName" -Data $User
        Set-RegString -ComputerName $_ -Hive "LocalMachine" -Key $path -Force -Value "DefaultPassword" -Data $Password

        if(Test-RegValue -ComputerName $_ -Hive "LocalMachine" -Key $path -Value "AutoLogonCount")
        {
            Remove-RegValue -ComputerName $_ -Hive "LocalMachine" -Key $path -Force -Value "AutoLogonCount"
        }
    }
}