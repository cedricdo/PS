function Get-VMRam
{
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        $View
    )
    
    $ram = $view.Config.MemoryAllocation
    [PSCustomObject]@{
        Host         = $view.Name
        Class        = "Virtual RAM"
        Manufacturer = $Null
        Model        = "" + [Math]::Round($view.Config.Hardware.MemoryMB/1024) + " Gio"
        Detail = [PSCustomObject]@{
            Lun         = [regex]::match($view.Layout.SwapFile, '\[([^]]+)\]').Groups[1].Value 
            Level       = $ram.Shares.Level
            Value       = $ram.Shares.Shares
            Reservation = $ram.Reservation
            Limit       = $ram.Limit
        }
    }
}