function Get-ShareEveryoneFullControlSecurityDescriptor
{
    $trustee        = ([wmiclass]'Win32_trustee').psbase.CreateInstance()
    $trustee.Domain = $Null
    $trustee.SID    = Get-TrusteeEveryoneSid

    # Access mask values
    $fullControl = 2032127
    $change      = 1245631
    $read        = 1179785

    $ace            = ([wmiclass]'Win32_ACE').psbase.CreateInstance()
    $ace.AccessMask = $fullControl
    $ace.AceFlags   = 3
    $ace.AceType    = 0
    $ace.Trustee    = $trustee

    $sd              = ([wmiclass]'Win32_SecurityDescriptor').psbase.CreateInstance()
    $sd.ControlFlags = 4
    $sd.DACL         = @($ace)
    $sd.group        = $trustee
    $sd.owner        = $trustee

	$sd
}
