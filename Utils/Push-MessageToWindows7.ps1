function Push-MessageToWindows7
{
    <#
    .SYNOPSIS
	    Send message to windows 7 host

    .DESCRIPTION
	    Send message to windows 7 host
	       
    .PARAMETER ComputerName
	    The host name

    .PARAMETER Message
        The message to send
    
    .PARAMETER CheckOS
        If defined, we check if the host is running windows 7
        
    .PARAMETER AllDomain
        If defined, the message will be sent to every computer on the domain which are running windows 7

    #>
    param(
        [string[]]$ComputerName = @(),
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [switch]$CheckOS,
        [switch]$AllDomain,
        [switch]$NoProgress
    )
    
    $path = "SYSTEM\CurrentControlSet\Control\Terminal Server"

    if($AllDomain)
    {
        $ComputerName = (Get-ADComputer -Filter {(OperatingSystem -like "*Windows 7*") -and (Enabled -eq $true)}).Name `
                            | where { $_ -like "X*" }
    }

    $count = 0

    $ComputerName | % {
        $count++
        if(!$NoProgress)
        {
            Write-Progress -Activity "Sending message" `
                           -Status "Sending to $_" `
                           -PercentComplete ($count / $ComputerName.Count * 100)
        }
        if(!(Test-Connection -ComputerName $_ -Count 1 -Quiet))
        {
            Write-Warning "$_ is unreachable..."
            return
        }

        if($CheckOS)
        {
            if((Get-WmiObject Win32_OperatingSystem -ComputerName $_ | select Caption) -notmatch "Windows 7")
            {
                Write-Warning "$_ does not run windows 7..."
                return
            }
        }

        try
        {
            if((Get-RegDWord -ComputerName $_ -Hive "LocalMachine" -Key $path -Value "AllowRemoteRPC").Data -eq "0")
            {
                Set-RegDWord -ComputerName $_ -Hive "LocalMachine" -Key $path -Force -Value "AllowRemoteRPC" -Data "1"
            }
        }
        catch
        {
            Write-Warning "Set-RegDWord failed on $_ ..."
            return
        }

        msg * /Server:$_ $Message
    }
}