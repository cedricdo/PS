function Get-DfsnLinkList
{
    <#
    .SYNOPSIS
	    Get the all dfs links on current domain

    .DESCRIPTION
	    Get the all dfs links on current domain
	       
    .PARAMETER Domain
	    The domain name

    #>
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
        [string]$Domain,
        [switch]$NoProgress
    )

    $path = @()
    $count = 0
    $namespace = Get-adobject -ldapfilter "(objectclass=msDFS-namespacev2)" -Properties *
    $namespace | % {
        $dsnRoot = $_.Name

        $count++
        if(!$NoProgress)
        {
            Write-Progress -Activity "Analyse DFS" `
                           -Status "Analyse $dsnRoot" `
                           -PercentComplete ($count / $namespace.Count * 100)
        }
        Get-ADObject -SearchBase $_.DistinguishedName -LDAPFilter "(objectclass=msDFS-Linkv2)" -Properties * | % {
            $linkPath = "\\" + $Domain + "\" + ($dsnRoot + $_.{msdfs-linkpathv2}).Replace("/", "\")
            $path += $linkPath
            if(!$NoProgress)
            {
                Write-Progress -Activity "Analyse DFS" `
                               -Status "Analyse $dsnRoot => $linkPath" `
                               -PercentComplete ($count / $namespace.Count * 100)
            }
        }
    }

    $path
}