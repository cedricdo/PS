function Get-VMNIC
{
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        $Vm
    )

    $result = @()

    $Vm | Get-NetworkAdapter | % {
        $result += [PSCustomObject]@{
            Host         = $Vm.Name
            Class        = "Virtual NIC"
            Manufacturer = $Null
            Model        = $_.NetworkName
            Detail       = [PSCustomObject]@{
                Driver    = $_.Type
                WakeOnLan = $_.WakeOnLanEnabled
            }
        }
    }

    $result
}