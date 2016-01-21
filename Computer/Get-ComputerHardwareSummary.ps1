function Get-ComputerHardwareSummary
{ 
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$ComputerName
    )

    $hardware = @()
	
    $ramData   = $ComputerName | Get-ComputerRAM
    $hardware += $ramData
    $hardware += $ComputerName | Get-ComputerCPU
    $hardware += $ComputerName | Get-ComputerOpticalDrive
    $hardware += $ComputerName | Get-ComputerDiskDrive
	$hardware += Get-ComputerMotherBoard -ComputerName $ComputerName -RamUsedSlot ($ramData.length)
	$hardware += Get-ComputerScreen $ComputerName

    $hardware
}
