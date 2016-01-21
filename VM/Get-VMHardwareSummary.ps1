function Get-VMHardwareSummary
{
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        $View,
        $DmzRange = "10.0.0"
    )

    if($View.Config.Template)
    {
        $o = Get-Template -Name $View.Name
        $ignoreWmi = $True
    }
    else
    {
        $o = Get-VM -Name $View.Name
        $ignoreWmi = ($o.Guest.IPAddress.length -eq 0) -or ($o.Guest.IPAddress[0] -like ($DmzRange + "*"))
    }
    
    $result = @()

    $result += $view | Get-VMCpu
    $result += $view | Get-VMRam
    $result += $o | Get-VMNIC
    $result += Get-VMHardDisk -View $View -Source $o -IgnoreWmi $ignoreWmi

    $result
}