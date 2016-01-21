function Get-VMHostNIC
{
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        $VMHost
    )

    $result = @()

    foreach($nic in ($VMHost | Get-EsxCli).network.nic.list())
    {
        $result += [PSCustomObject]@{
            Host         = $VMHost.Name
            Class        = "NIC"
            Manufacturer = ""
            Model        = $nic.Description
            Detail       = [PSCustomObject]@{}
        }
    }

    $result
}