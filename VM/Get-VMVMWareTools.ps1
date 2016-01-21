function Get-VMVMWareTools
{
    param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        $View
    )

    [PSCustomObject]@{
        Version = $View.Config.Tools.ToolsVersion
        Status  = $View.Guest.ToolsVersionStatus
    }
}