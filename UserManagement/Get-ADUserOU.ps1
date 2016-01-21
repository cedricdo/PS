function Get-ADUserOU
{
	param(
		[Parameter(Mandatory=$True,ValueFromPipeline=$True)]
		[string]$User
	)

	$adUser = Get-ADUser -Identity $User
	$adsiUser = [ADSI]"LDAP://$($adUser.DistinguishedName)"
	([ADSI]($adsiUser.Parent)).distinguishedName
}
