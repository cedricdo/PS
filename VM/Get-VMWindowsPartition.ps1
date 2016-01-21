function Get-VMWindowsPartition
{
    param(
        [Parameter(Mandatory=$True)]
        $View
    )

    $result = @{}

    $scsi       = $view.Config.Hardware.Device | where { $_.DeviceInfo.Label -match "SCSI Controller" }
    $deviceList = $view.Config.Hardware.Device | where { $_.ControllerKey -eq $scsi.Key }
    $diskDrives = Get-WmiObject Win32_DiskDrive -ComputerName $view.Name -ErrorAction SilentlyContinue | where { $_.SCSIBus -eq $scsi.BusNumber } | select DeviceID, SCSIBus, SCSITargetId
    foreach($disk in $diskDrives)
    {
        $match = $deviceList | where { $_.UnitNumber -eq $disk.SCSITargetId }
        if($match -eq $Null)
        {
            continue
        }
        
        $result[$match.DiskObjectId] = [string[]]@()

        $partitionQuery = 'ASSOCIATORS OF {Win32_DiskDrive.DeviceID="' +
                          $disk.DeviceID.replace('\','\\') +
                          '"} WHERE AssocClass=Win32_DiskDriveToDiskPartition'
        $partitionList = @(Get-WmiObject -ComputerName $view.Name -Query $partitionQuery | sort StartingOffset | Select DeviceID)

        foreach($partition in $partitionList)
        {
            $volumeQuery = 'ASSOCIATORS OF {Win32_DiskPartition.DeviceID="' +
                           $partition.DeviceID +
                           '"} WHERE AssocClass=Win32_LogicalDiskToPartition'
            $result[$match.DiskObjectId] += @(Get-WmiObject -ComputerName $view.Name -Query $volumeQuery | % { $_.Name.replace(":", "") })
        }
    }

    $result

}