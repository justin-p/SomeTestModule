Function Get-UPNSuffixesFromAD {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        $Identity,
        $Server
    )
    Try {
        if ($server) {
            Return (Get-ADForest -Identity $Identity -Server $Server).UPNSuffixes
        } Else  {
            Return (Get-ADForest -Identity $Identity).UPNSuffixes
        }
    } Catch {
        $PSCmdlet.ThrowTerminatingError($PSitem)
    }
}