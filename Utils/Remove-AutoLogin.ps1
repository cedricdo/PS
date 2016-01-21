function Remove-AutoLogin
{
    <#
    .SYNOPSIS
	    Remove autologin on an host

    .DESCRIPTION
	    Remove autologin on an host
	       
    .PARAMETER ComputerName
	    The host name
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$ComputerName,
        [switch]$NoProgress
    )

    $count = 0

    $ComputerName | % {
        $count++
        if(!$NoProgress)
        {
            Write-Progress -Activity "Removing autologin" `
                           -Status "Working on $_" `
                           -PercentComplete ($count / $ComputerName.Count * 100)
        }
        If(!(Test-Connection -ComputerName $_ -Count 1 -Quiet))
        {
            Write-Warning "$_ is unreachable..." 
            return
        }

        $path   = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    
        Set-RegString -ComputerName $_ -Hive "LocalMachine" -Key $path -Force -Value "AutoAdminLogon" -Data "0"
        Set-RegString -ComputerName $_ -Hive "LocalMachine" -Key $path -Force -Value "DefaultDomainName" -Data ""
        Set-RegString -ComputerName $_ -Hive "LocalMachine" -Key $path -Force -Value "DefaultUserName" -Data ""

        if(Test-RegValue -ComputerName $_ -Hive "LocalMachine" -Key $path -Value "DefaultPassword")
        {
            Remove-RegValue -ComputerName $_ -Hive "LocalMachine" -Key $path -Force -Value "DefaultPassword"
        }
    }
}