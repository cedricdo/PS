function Get-ComputerRAM
{
	param(
		[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
		$ComputerName
	)

	Get-WmiObject Win32_PhysicalMemory -ComputerName $ComputerName | % {
        [pscustomobject]@{
            Host         = $ComputerName
            Class        = "RAM"
            Manufacturer = $_.Manufacturer
            Model        = ($_.Capacity | Get-HRSize) + " " + $_.Speed + " Mhz"
            Detail       = [PSCustomObject]@{}
        }
    }
}
