function Get-HRSize 
{
    <#

    .SYNOPSIS
        Convert a number of octets on the most appropriate unit

    .DESCRIPTION    
        Convert a number of octets on the most appropriate unit

    .PARAMETER $bytes
        The number to convert

    .NOTE
        Source : http://www.uvm.edu/~gcd/2013/01/which-disk-is-that-volume-on/

    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [INT64] $bytes
    )
    process {
        if     ( $bytes -gt 1pb ) { "{0:N2} Po" -f ($bytes / 1pb) }
        elseif ( $bytes -gt 1tb ) { "{0:N2} To" -f ($bytes / 1tb) }
        elseif ( $bytes -gt 1gb ) { "{0:N2} Go" -f ($bytes / 1gb) }
        elseif ( $bytes -gt 1mb ) { "{0:N2} Mo" -f ($bytes / 1mb) }
        elseif ( $bytes -gt 1kb ) { "{0:N2} Ko" -f ($bytes / 1kb) }
        else   { "{0:N} Bytes" -f $bytes }
    }
}