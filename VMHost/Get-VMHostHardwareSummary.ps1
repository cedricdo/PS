function Get-VMHostHardwareSummary
{
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        $VMHost
    )

    $result = @()

    $result += $VMHost | Get-VMHostCPU
    $result += $VMHost | Get-VMHostRAM 
    $result += $VMHost | Get-VMHostNIC
    $result += $VMHost | Get-VMHostHardDisk

    $result
}