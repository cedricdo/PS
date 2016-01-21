function Get-ComputerCPU
{
	param(
		[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
		$ComputerName
	)

	Get-WmiObject Win32_Processor -ComputerName $ComputerName | % {
        [pscustomobject]@{
            Host         = $ComputerName
            Class        = "CPU"
            Manufacturer = $_.Manufacturer
            Model        = $_.Name
            Detail = [PSCustomObject]@{
                ClockRate      = $_.CurrentClockSpeed
                MaxClockRate   = $_.MaxClockSpeed
                Core           = $_.NumberOfCores
                HyperThreading = $_.NumberOfLogicalProcessors -gt $_.NumberOfCores
                Socket         = $_.SocketDesignation
            }
        }
    }
}
