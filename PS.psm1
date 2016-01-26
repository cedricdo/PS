function Test-ElevatedShell
{
	$user = [Security.Principal.WindowsIdentity]::GetCurrent()
	(New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if(!(Test-ElevatedShell))
{

$warning=@"
	To run commands exposed by this module on Windows Vista, Windows Server 2008, and later versions of Windows,
	you must start an elevated Windows PowerShell console.
"@

	Write-Warning $warning	
	Exit
}

# Import required module
Import-Module PSRemoteRegistry
Import-Module NTFSSecurity

# Include *.ps1 and export the functions
Get-ChildItem -Recurse -Path $PSScriptRoot\*.ps1 | Foreach-Object{ . $_.FullName }
Export-ModuleMember –Function @(Get-Command –Module $ExecutionContext.SessionState.Module | Where-Object {$_.Name -ne "Test-ElevatedShell"})

# Load config file and export variable
$myDir    = Split-Path -Parent $MyInvocation.MyCommand.Path
if(Test-Path "$MyDir\Settings.xml")
{
	[xml]$xml = Get-Content "$MyDir\Settings.xml"
	$config   = $xml.Settings
	Export-ModuleMember -variable config
}