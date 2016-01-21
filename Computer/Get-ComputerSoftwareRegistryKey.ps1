function Get-ComputerSoftwareRegistryKey
{
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [String]$ComputerName
    )

    $result = @()

    $result += [PSCustomObject]@{
        Hive = [Microsoft.Win32.RegistryHive]::LocalMachine
        Key  = @(
            "Software\Microsoft\WINDOWS\CurrentVersion\Uninstall",
            "Software\Wow6432Node\Microsoft\WINDOWS\CurrentVersion\Uninstall"
        )
    }

    $baseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey(
        [Microsoft.Win32.RegistryHive]::Users,
        $ComputerName
    )
	try
	{
		$result += [PSCustomObject]@{
			Hive = [Microsoft.Win32.RegistryHive]::Users
			Key  = $baseKey.OpenSubKey('\').GetSubKeyNames() | % { 
				$_ + "\Software\Microsoft\Windows\CurrentVersion\Uninstall"
			}
		}
	}
	catch {}

    $result
}