function Get-ComputerDiskDrive
{
	param(
		[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
		$ComputerName
	)

	Get-WmiObject Win32_diskDrive -ComputerName $ComputerName | % {
        if($_.InterfaceType -eq "IDE")
        {
            $int = "IDE/SATA"
        }
        else
        {
            $int = $_.InterfaceType
        }
        [pscustomobject]@{
            Host         = $ComputerName
            Class        = $int
            Manufacturer = $_.Manufacturer
            Model        = $_.Model
            Detail = [PSCustomObject]@{
                Status = $_.Status
                Size   = [Math]::Round($_.Size/1GB)
            }
        }
    }
}
