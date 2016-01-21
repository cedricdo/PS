function Get-ComputerMotherBoard
{
	param(
		[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
		$ComputerName,
		[int]$RamUsedSlot = 0
	)
	
	$mb = Get-WmiObject Win32_BaseBoard -ComputerName $ComputerName
    $nbSlotRam = (Get-WmiObject Win32_PhysicalMemoryArray -ComputerName $ComputerName).MemoryDevices
    [pscustomobject]@{
        Host         = $ComputerName
        Class        = "Mainboard"
        Manufacturer = $mb.Manufacturer
        Model        = $mb.Product
        Detail       = [PSCustomObject]@{
            RamUsedSlot = $nbSlotRam
            RamFreeSlot = $nbSlotRam - $RamUsedSlot
        }
    }
}
    