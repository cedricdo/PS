function Get-ComputerUSBDevice
{
	param(
		[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
		$ComputerName
	)

	gwmi -ComputerName $ComputerName Win32_USBControllerDevice | % { [wmi]$_.Dependent } | select name,caption,description,manufacturer,service,status
}
