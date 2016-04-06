function Get-ComputerDotNetVersion
{
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [String[]]$ComputerName
    )

    $result = @()

    foreach($Computer in $ComputerName)
    {
        $keys = Get-RegKey -Hive LocalMachine -Key "SOFTWARE\Microsoft\NET Framework Setup\NDP" -Recurse -ComputerName $Computer `
              | select Key | where { $_.Key.Split("\")[-1] -match '^(?!S)\p{L}' }
        foreach($key in $keys)
        {
            $value = Get-RegValue -Hive LocalMachine -Key $key.key -ComputerName $Computer
            if($value.Count -gt 0)
            {
                $result += [PSCustomObject]@{
                    Computer = $Computer
                    Name = $key.key
                    Version = ($value | where { $_.Value -eq "version" }).Data
                }
            }
        }
    }

    $result
}