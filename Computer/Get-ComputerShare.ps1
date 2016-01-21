function Get-ComputerShare
{
    <#
    .SYNOPSIS
	    Get the share of an host

    .DESCRIPTION
	    Get the share of an host
	       
    .PARAMETER ComputerName
	    The host name

    .PARAMETER Domain
        The domain of the server	
		
    .OUTPUTS
    array

    #>
    [cmdletbinding()]
    param(
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelinebyPropertyName=$true
        )]
        [Alias('Name')]
        [string[]]$ComputerName,
        [Parameter(Mandatory=$true)]
        [string]$Domain,
        [switch]$NoProgress
    )

    PROCESS
    {
        $result = @()

        if(!$NoProgress)
        {
            Write-Progress -Activity "Analyse share" `
                           -Status "Analyse DFS path" `
                           -PercentComplete 0
        }
        $dfsList = Get-DfsnLinkList -Domain $Domain -NoProgress `
                       | % { Get-DfsnFolderTarget $_ } `
                       | select Path,TargetPath

        $countComputer = 1

        foreach($c in $ComputerName)
        {
            $percent = $countComputer++ / $ComputerName.Count * 100
            if(!$NoProgress)
            {
                Write-Progress -Activity "Analyse share" `
                               -Status "Analyse $c" `
                               -PercentComplete $percent
            }
            

            if((Test-Connection -ComputerName $c -Count 1 -Quiet) -eq $false)
            {
                Write-Warning "$c is unreachable..."
                continue
            }
            
            $share = Get-WmiObject Win32_Share -ComputerName $c | Where { $_.Type -eq 0 }
            $countShare = 0
            foreach($s in $share)
            {
                $countShare++
                $shareName = "\\" + $c + "\" + $s.Name
                
                if(!$NoProgress)
                {
                    Write-Progress -Activity "Analyse share" `
                                   -Status "Analyse $c => $shareName ($countShare / $($share.Count) shares)" `
                                   -PercentComplete $percent
                }

                $dfs = $dfsList | Where { $_.TargetPath -eq $shareName }
               
                Get-NTFSAccess -Path $shareName -ErrorAction Ignore | % {
                    $result += [pscustomobject]@{
                        Host        = $c
                        Name        = $s.Name
                        Path        = "\\$c\$($s.Path.Replace(':', '$'))"
                        Dfs         = $dfs.Path
                        Resource    = $_.Account.AccountName
                        Access      = $_.AccessRights.ToString()
                        Type        = $_.AccessControlType.ToString()
                        IsInherited = $_.IsInherited
                        Source      = "NTFS"
                    }
                }

                Get-SharePermissions -computername $c -sharename $s.Name | % {
                    $result += [pscustomobject]@{
                        Host        = $c
                        Name        = $s.Name
                        Path        = "\\$c\$($s.Path.Replace(':', '$'))"
                        Dfs         = $dfs.Path
                        Resource    = $_.Domain + "\" + $_.ID
                        Access      = $_.AccessMask
                        Type        = $_.AceType
                        IsInherited = $false
                        Source      = "Share"
                    }
                }
            }
        }

        $result
    }
}