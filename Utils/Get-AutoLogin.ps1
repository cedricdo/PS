function Get-AutoLogin
{
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$ComputerName
    )

    $path   = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    $item = [pscustomobject]@{
        AutoAdminLogon    = "";
        DefaultDomainName = "";
        DefaultUserName   = "";
        DefaultPassword   = "";
        AutoLogonCount    = ""
    }

    if(Test-RegValue -ComputerName $ComputerName -Hive "LocalMachine" -Key $path -Value "AutoAdminLogon")
    {
        $item.AutoAdminLogon = Get-RegString -ComputerName $ComputerName -Hive "LocalMachine" -Key $path -Value "AutoAdminLogon" | % { $_.Data }
    }
    if(Test-RegValue -ComputerName $ComputerName -Hive "LocalMachine" -Key $path -Value "DefaultDomainName")
    {
        $item.DefaultDomainName = Get-RegString -ComputerName $ComputerName -Hive "LocalMachine" -Key $path -Value "DefaultDomainName" | % { $_.Data }
    }
    if(Test-RegValue -ComputerName $ComputerName -Hive "LocalMachine" -Key $path -Value "DefaultUserName")
    {
        $item.DefaultUserName = Get-RegString -ComputerName $ComputerName -Hive "LocalMachine" -Key $path -Value "DefaultUserName" | % { $_.Data }
    }
    if(Test-RegValue -ComputerName $ComputerName -Hive "LocalMachine" -Key $path -Value "DefaultPassword")
    {
        $item.DefaultPassword = Get-RegString -ComputerName $ComputerName -Hive "LocalMachine" -Key $path -Value "DefaultPassword" | % { $_.Data }
    }
    if(Test-RegValue -ComputerName $ComputerName -Hive "LocalMachine" -Key $path -Value "AutoLogonCount")
    {
        $item.AutoLogonCount = Get-RegString -ComputerName $ComputerName -Hive "LocalMachine" -Key $path -Value "AutoLogonCount" | % { $_.Data }
    }

    $item
}