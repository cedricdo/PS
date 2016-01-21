function Get-ComputerSoftware
{
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [String[]]$ComputerName
    )

    $result = @()

    foreach($computer in $ComputerName)
    {
        foreach($hive in (Get-ComputerSoftwareRegistryKey $computer))
        {
            $baseKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($hive.Hive, $computer)
            foreach($key in $hive.Key)
            {
                try
                {
                    $regKey = $baseKey.OpenSubKey($key)
                    if($regKey)
                    {
                        foreach($subname in $regKey.GetSubKeyNames())
                        {
                            $subKey = $regKey.OpenSubKey($subname)
                            $name = $subKey.GetValue('DisplayName')
                            if($name)
                            {
                                $result += [PSCustomObject]@{
                                    Host        = $computer
                                    Name        = $name
                                    Version     = $subkey.GetValue('DisplayVersion')
                                    Publisher   = $subkey.GetValue('Publisher')
                                    InstallDate = $subkey.GetValue('InstallDate')
                                }
                            }
                        }
                    }
                }
                catch {}
            }
        }
    }
    
    $result
}