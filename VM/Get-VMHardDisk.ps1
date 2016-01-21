function Get-VMHardDisk
{
    param(
        [Parameter(Mandatory=$True)]
        $View,
        [Parameter(Mandatory=$True)]
        $Source,
        [Parameter(Mandatory=$True)]
        $IgnoreWmi
    )

    $result   = @()
    $diskList = $Source | Get-HardDisk

    if((-not $IgnoreWmi) -and (-not $Source.Config.Template) -and ($Source.Guest.GuestFamily -match "windows") -and (Test-Connection $Source.Name -Quiet))
    {
        $partitionList = Get-VMWindowsPartition -View $View
    }
    else
    {
        $partitionList = @{}
    }

    foreach($disk in $diskList)
    {
        $result += [PSCustomObject]@{
            Host  = $view.Name
            Class = "Virtual Disk"
            Manufactuer = $Null
            Model       = $Null
            Detail = [PSCustomObject]@{
                Lun       = [regex]::match($disk.Filename, '\[([^]]+)\]').Groups[1].Value 
                Size      = $disk.CapacityGB
                Format    = $disk.StorageFormat
                Partition = $partitionList[[string]$disk.ExtensionData.DiskObjectId]
            }
        }
    }

    $result
}