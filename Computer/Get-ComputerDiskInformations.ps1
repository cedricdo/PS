function Get-ComputerDiskInformations
{
    <#

    .SYNOPSIS
        Get a list of disk, partition and volume of an host

    .DESCRIPTION 
        Get a list of disk, partition and volume of an host

    .PARAMETER ComputerName
        The name of the host

    .NOTE
        The result is an object following this structure :
        - Disk.Index -> disk index on the system
        - Disk.Size -> disk size (bytes)
        - Disk.Model -> disk model
        - Disk.SerialNumber -> disk serial number
        - Disk.Partitions -> number of partition on the disk
        - Disk.DeviceID -> disk system id
        - Disk.PartitionList -> list of partitions
        -      Partition.Index -> partition index on the disk
        -      Partition.Size -> partition size (byte)
        -      Partition.FreeSpace -> free size on the parition (byte)
        -      Partition.DeviceID -> parition system id
        -      Partition.VolumeList -> list of volumes
        -                Volume.Name -> volume name
        -                Volume.FileSystem -> filesystem type (ntfs, fat32, ...)
        -                Volume.Size -> volume size (byte)
        -                Volume.FreeSpace -> free size on the volume (byte)

        A partition will have no volume if no letter's has been attribued

    #>
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$ComputerName,
        [switch]$NoProgress
    )

    $information = @()

    # Get the physical disk
    $diskDrives = Get-WmiObject -ComputerName $ComputerName Win32_DiskDrive | sort Index | select Index, Size, Model, SerialNumber, Partitions, DeviceID
    $diskDrivesCount = $diskDrives.Count
    if($diskDrivesCount -eq $Null)
    {
        $diskDrivesCount = 1
    }
    $count = 0

    foreach($disk in $diskDrives)
    {
        $count++
        if(!$NoProgress)
        {
            Write-Progress -Activity "Analyse disk" `
                           -Status "Analyse $($disk.DeviceID)" `
                           -PercentComplete ($count / $diskDrivesCount * 100)
        }
        Add-Member -InputObject $disk -MemberType NoteProperty -Name "PartitionList" -Value @()
        $information += $disk

        # Get the partitions
        $partitionQuery = 'ASSOCIATORS OF {Win32_DiskDrive.DeviceID="' +
                          $disk.DeviceID.replace('\','\\') +
                          '"} WHERE AssocClass=Win32_DiskDriveToDiskPartition'
        $disk.PartitionList = @(Get-WmiObject -ComputerName $ComputerName -Query $partitionQuery | sort StartingOffset | Select Index, Size, FreeSpace, DeviceID)
        foreach($partition in $disk.PartitionList)
        {
            Add-Member -InputObject $partition -MemberType NoteProperty -Name "VolumeList" -Value @()

            # Get the volumes
            $volumeQuery = 'ASSOCIATORS OF {Win32_DiskPartition.DeviceID="' +
                           $partition.DeviceID +
                           '"} WHERE AssocClass=Win32_LogicalDiskToPartition'
            $partition.VolumeList = @(Get-WmiObject -ComputerName $ComputerName -Query $volumeQuery | select Name, FileSystem, Size, FreeSpace)
            
        }
    }

    $information
}