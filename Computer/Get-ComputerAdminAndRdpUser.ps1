function Get-ComputerAdminAndRdpUser
{
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$ComputerName
    )

    @("Administrateurs", "Utilisateurs du Bureau à distance", "Administrators", "Remote Desktop Users") | % {
        Get-ComputerLocalGroupMember -ComputerName $ComputerName -GroupName $_
    }
}