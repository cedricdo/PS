function Get-SharePermissions
{
    <#

    .SYNOPSIS
        Get share access rights

    .DESCRIPTION    
        Get share access rights

    .PARAMETER ComputerName
        The name of the host where the share is
        
    .PARAMETER ShareName
        The name of the share

    .NOTE
        Source : http://www.peetersonline.nl/2008/11/listing-share-permissions-for-remote-shares/

    #>
    
	param(
        [Parameter(Mandatory=$true)]
        [string]$computername,
        [Parameter(Mandatory=$true)]
        [string]$sharename
    )
	$ShareSec = Get-WmiObject -Class Win32_LogicalShareSecuritySetting -ComputerName $computername
	ForEach ($ShareS in ($ShareSec | Where {$_.Name -eq $sharename}))
	{
		$SecurityDescriptor = $ShareS.GetSecurityDescriptor()
		$myCol = @()
		ForEach ($DACL in $SecurityDescriptor.Descriptor.DACL)
		{
			$myObj = "" | Select Domain, ID, AccessMask, AceType
			$myObj.Domain = $DACL.Trustee.Domain
			$myObj.ID = $DACL.Trustee.Name
			Switch ($DACL.AccessMask)
			{
				2032127 {$AccessMask = "FullControl"}
				1179785 {$AccessMask = "Read"}
				1180063 {$AccessMask = "Read, Write"}
				1179817 {$AccessMask = "ReadAndExecute"}
				-1610612736 {$AccessMask = "ReadAndExecuteExtended"}
				1245631 {$AccessMask = "ReadAndExecute, Modify, Write"}
				1180095 {$AccessMask = "ReadAndExecute, Write"}
				268435456 {$AccessMask = "FullControl (Sub Only)"}
				default {$AccessMask = $DACL.AccessMask}
			}
			$myObj.AccessMask = $AccessMask
			Switch ($DACL.AceType)
			{
				0 {$AceType = "Allow"}
				1 {$AceType = "Deny"}
				2 {$AceType = "Audit"}
			}
			$myObj.AceType = $AceType
			Clear-Variable AccessMask -ErrorAction SilentlyContinue
			Clear-Variable AceType -ErrorAction SilentlyContinue
			$myCol += $myObj
		}
	}
	Return $myCol
}