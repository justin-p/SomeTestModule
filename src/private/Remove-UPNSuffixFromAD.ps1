Function Remove-UPNSuffixFromAD {
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param (
        [Parameter(Mandatory=$true)]
        $Identity,
        $Server,
        $UPNSuffix
    )
    Try {
        If ($PSCmdlet.ShouldProcess("Removing UPNSuffix $($UPNSuffix) on path $($Identity)")) {
            if ($server) {
                Set-ADForest -Identity $Identity -UPNSuffixes @{Remove=$($UPNSuffix)} -Server $server
            } Else  {
                Set-ADForest -Identity $Identity -UPNSuffixes @{Remove=$($UPNSuffix)}
            }
        }
   } Catch {
        $PSCmdlet.ThrowTerminatingError($PSitem)
   }
}