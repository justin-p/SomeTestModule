Function Add-UPNSuffixToAD {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        $Identity,
        $Server,
        $UPNSuffix
    )
    Try {
        if ($server) {
            Set-ADForest -Identity $Identity -UPNSuffixes @{Add=$($UPNSuffix)} -Server $server
        } Else  {
            Set-ADForest -Identity $Identity -UPNSuffixes @{Add=$($UPNSuffix)}
        }
    } Catch {
        $PSCmdlet.ThrowTerminatingError($PSitem)
    }
}