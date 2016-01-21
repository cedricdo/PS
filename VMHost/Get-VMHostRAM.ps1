﻿function Get-VMHostRAM
{
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        $VMHost
    )

    $typeMap = @{
        0  = "Unknown"
        1  = "Other"
        2  = "DRAM"
        3  = "Synchronous DRAM"
        4  = "Cache DRAM"
        5  = "EDO"
        6  = "EDRAM"
        7  = "VRAM"
        8  = "SRAM"
        9  = "RAM"
        10 = "ROM"
        11 = "Flash"
        12 = "EEPROM"
        13 = "FEPROM"
        14 = "EPROM"
        15 = "CDRAM"
        16 = "3DRAM"
        17 = "SDRAM"
        18 = "SGRAM"
        19 = "RDRAM"
        20 = "DDR"
        21 = "DDR2"
        22 = "BRAM"
        23 = "FB-DIMM"
        24 = "DDR3"
        25 = "FBD2"
    }

    $result = @()

    foreach($module in Get-VMHostWSManInstance -VMHost $VMHost -class CIM_PhysicalMemory -ignoreCertFailures)
    {
        if($module.IsSpeedInMhz)
        {
            $speed = $module.MaxMemorySpeed
        }
        else
        {
            $speed = $module.Speed
        }
        
        $result += [PSCustomObject]@{
            Host         = $VMHost.Name
            Class        = "RAM"
            Manufacturer = $module.Manufacturer
            Model        = $typeMap[[int]$module.MemoryType] + " " + ($module.Capacity/1GB) + " Gio " + $speed + " Mhz"
            Detail       = [PSCustomObject]@{
                Bank = $module.ElementName
            }
        }
    }

    $result
}