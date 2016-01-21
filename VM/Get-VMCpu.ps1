function Get-VMCpu
{
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        $View
    )

    $result = @()

    $numberOfCpu = $view.Config.Hardware.NumCpu / $view.Config.Hardware.NumCoresPerSocket
    for($i = 0; $i -lt $numberOfCpu; $i++)
    {
        $cpu = $view.Config.CpuAllocation
        $result += [PSCustomObject]@{
            Host        = $view.Name
            Class       = "Virtual CPU"
            Manufacturer = $Null
            Model       = $Null
            Detail = [PSCustomObject]@{
                Core        = $view.Config.Hardware.NumCoresPerSocket
                Level       = $cpu.Shares.Level
                Value       = $cpu.Shares.Shares
                Reservation = $cpu.Reservation
                Limit       = $cpu.Limit
            }
        }
    }

    $result
}