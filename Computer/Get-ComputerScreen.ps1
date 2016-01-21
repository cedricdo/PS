function Get-ComputerScreen
{
	param(
		[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
		[String[]]$Computer
	)

	$result = @()

	foreach($c in $Computer)
	{
		try
		{
			# best case, windows vista or higher
			gwmi WmiMonitorID -Namespace root\wmi -ComputerName $c -ErrorAction Stop | % {
				$result += [PSCustomObject]@{
					Host         = $c
					Class        = "Screen"
					Manufacturer = (($_.ManufacturerName | where { $_ -ne 0 } | % { [char]$_ }) -join "").Trim()
					Model        = (($_.UserFriendlyName | where { $_ -ne 0 } | % { [char]$_ }) -join "").Trim()
					Detail       = [pscustomobject]@{
						SerialNumber = (($_.SerialNumberID | where { $_ -ne 0 } | % { [char]$_ }) -join "").Trim()
					}
				}
			}
		}
		catch
		{
			# not fun, xp or older
			$knownSerial = @()
			$reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $c)
			$displayKey =  $reg.OpenSubKey("SYSTEM\\CurrentControlSet\\Enum\DISPLAY")
			foreach($HID in $displayKey.getSubKeyNames())
			{
				$hidKey = $reg.OpenSubKey("SYSTEM\\CurrentControlSet\\Enum\\DISPLAY\\$HID") 
				foreach($DID in $hidKey.getSubKeyNames())
				{
					if(-not $reg.OpenSubKey("SYSTEM\\CurrentControlSet\\Enum\\DISPLAY\\$HID\\$DID\\Control"))
					{
						continue
					}
					$deviceParameter = $reg.OpenSubKey("SYSTEM\\CurrentControlSet\\Enum\\DISPLAY\\$HID\\$DID\\Device Parameters")
					$edid = ($deviceParameter.GetValue("EDID") | % { [char]$_ }) -join ""
					$o = [PSCustomObject]@{
						Host         = $c
						Class        = "Screen"
						Manufacturer = "Undefined"
						Model        = "Undefined"
						Detail       = [pscustomobject]@{
							SerialNumber = "Undefined"
						}
					}
					$descriptor = [char]0x00 + [char]0x00 + [char]0x00 + [char]0xFF + [char]0x00
					if($edid -match "$descriptor([^"+ [char]0x00 + "]+)")
					{
						if(-not $knownSerial.Contains($Matches[1].Trim()))
						{
							$o.Detail.SerialNumber = $Matches[1].Trim()
							$knownSerial += $Matches[1].Trim()
						}
						else
						{
							continue
						}
					}
					else
					{
						continue
					}
					$descriptor = [char]0x00 + [char]0x00 + [char]0x00 + [char]0xFC + [char]0x00
					if($edid -match "$descriptor([^"+ [char]0x00 + "]+)")
					{
						$o.Model = $Matches[1]
					}

					$result += $o
				}
			}

			# Not fun at all
			if($knownSerial.Length -eq 0)
			{
				Get-WmiObject Win32_DesktopMonitor -ComputerName $c | % {
		 			if((-not $_.ScreenWidth) -or (-not $_.ScreenHeight))
					{
					   $detail = [PSCustomObject]@{}
					}
					else
					{
						$detail = [PSCustomObject]@{
							Width  = $_.screenWidth
							Height = $_.screenHeight
						}
					}
					$result += [pscustomobject]@{
						Host         = $c
						Class        = "Screen"
						Manufacturer = $_.MonitorManufacturer
						Model        = $_.Name
						Detail       = $detail
					}
				}
			}
		}
	}

	$result
}
