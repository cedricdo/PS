function Get-TrusteeEveryoneSid
{
	$sid = New-Object Security.Principal.SecurityIdentifier([System.Security.Principal.WellKnownSidType]::WorldSid, $Null)
    [byte[]]$ba = ,0 * $sid.BinaryLength      
    [void]$sid.GetBinaryForm($ba,0)  
    $ba
}
