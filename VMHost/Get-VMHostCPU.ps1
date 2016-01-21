function Get-VMHostCPU
{
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        $VMHost
    )

    $result = @()
    foreach($cpu in $VMHost.ExtensionData.Hardware.CpuPkg)
    {
        $core = $VMHost.ExtensionData.Hardware.CpuInfo.NumCpuCores
        if($VMHost.HyperthreadingActive)
        {
            $core /= 2
        }

        $result += [PSCustomObject]@{
            Host         = $VMHost.Name
            Class        = "CPU"
            Manufacturer = $cpu.Vendor
            Model        = $cpu.Description
            Detail       = [PSCustomObject]@{
                Core           = $core
                MaxClockRate   = [Math]::round($cpu.Hz / 1MB)
                HyperThreading = $VMHost.HyperthreadingActive
            }
        }
    }

    $result

}