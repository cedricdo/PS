function Get-SystemUptime {
	param(
		[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
		[String]$ComputerName
	)

    $operatingSystem = Get-WmiObject Win32_OperatingSystem -ComputerName $ComputerName
    "$((Get-Date) - ([Management.ManagementDateTimeConverter]::ToDateTime($operatingSystem.LastBootUpTime)))"
}
