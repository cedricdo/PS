function Get-VMHostHardDisk
{
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        $VMHost
    )

    $result = @()

    foreach($disk in (Get-ScsiLun -VmHost $VMHost | where { $_.IsLocal }))
    {
        if($disk.LunType -eq "disk")
        {
            $detail = [PSCustomObject]@{ Size = [Math]::Round($disk.CapacityGB) }
        }
        else
        {
            $detail = [PSCustomObject]@{}
        }
        $result += [PSCustomObject]@{
            Host         = $VMHost.Name
            Class        = $disk.LunType
            Manufacturer = $disk.ExtensionData.Vendor
            Model        = $disk.Model
            Detail       = $detail
        }
    }

    $result
}