function Get-ExchangeSession
{
	param(
		[Parameter(Mandatory=$True)]
		[string]$Server
	)

	
	New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionURI "http://$Server/powershell/" -Authentication kerberos
}
