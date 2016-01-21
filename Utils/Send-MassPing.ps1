Workflow Send-MassPing
{  
     <#
    .SYNOPSIS
	    Ping a lost of addresses as fast as possible without getting any result

    .DESCRIPTION
	    Ping a lost of addresses as fast as possible without getting any result

    #>   
    param([string[]]$ips)  

    foreach -parallel($ip in $ips)  
    {  
        start ping "-n 1 -w 5 $ip"
    }  
}