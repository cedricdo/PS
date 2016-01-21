function Get-ComputerPrinterList
{
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$ComputerName,
        [switch]$NoProgress
    )

    $list = @()
    $Printers = Get-WmiObject Win32_Printer -ComputerName $ComputerName

    $count = 0

    ForEach ($Printer in $Printers)
    {
        $count++
        if(!$NoProgress)
        {
            Write-Progress -Activity "Analyse printers" `
                           -Status "Analyse $($Printer.Name)" `
                           -PercentComplete ($count / $Printers.Count * 100)
        }
        If ($Printer.Name -notlike "Microsoft XPS*")
        {
            $item = [pscustomobject]@{
                Host          = $ComputerName
                Name          = $Printer.Name
                Location      = $Printer.Location
                Comment       = $Printer.Comment
                IPAddress     = $Null
                DriverName    = $Null
                DriverVersion = $Null
                DriverFile    = $Null
                IsShared      = $Null
                ShareName     = $Null
				PortName      = $Printer.PortName
            }
            $list += $item
            
            If ($Printer.PortName -notlike "*\*")
            {  
                $Ports = Get-WmiObject Win32_TcpIpPrinterPort -Filter "name = '$($Printer.Portname)'" -ComputerName $ComputerName
                ForEach ($Port in $Ports)
                {
                    $item.IPAddress = $Port.HostAddress
                }
            }
            
            $Drivers = Get-WmiObject Win32_PrinterDriver -Filter "__path like '%$($Printer.DriverName)%'" -ComputerName $ComputerName
            ForEach ($Driver in $Drivers)
            {   
                $Drive = $Driver.DriverPath.Substring(0,1)
                $item.DriverVersion = (Get-ItemProperty ($Driver.DriverPath.Replace("$Drive`:","\\$ComputerName\$Drive`$"))).VersionInfo.ProductVersion
                $item.DriverFile = Split-Path $Driver.DriverPath -Leaf
            }
             
            $item.DriverName = $Printer.DriverName
            $item.IsShared   = $Printer.Shared
            $item.ShareName  = $Printer.ShareName
        }
    }

    $list
}