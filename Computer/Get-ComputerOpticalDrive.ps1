function Get-ComputerOpticalDrive
{
	param(
		[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
		$ComputerName
	)

	Get-WmiObject Win32_CDROMDrive -ComputerName $ComputerName | % {
        [pscustomobject]@{
            Host         = $ComputerName
            Class        = $_.MediaType
            Manufacturer = $_.Manufacturer
            Model        = $_.Name
            Detail       = [PSCustomObject]@{}
        }
    }
}
