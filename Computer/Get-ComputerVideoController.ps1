function Get-ComputerVideoController
{
	param(
		[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
		$ComputerName
	)
	
    Get-WmiObject Win32_VideoController -ComputerName $ComputerName | where { $_.Caption -notmatch "Dameware" } | % {
       [pscustomobject]@{
            Host         = $ComputerName
            Class        = "GPU"
            Manufacturer = ""
            Model        = $_.Name
            Detail       = [PSCustomObject]@{}
        }
    }
}
