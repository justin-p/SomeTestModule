Function ConvertTo-IPaddress {
    [CmdletBinding()]
    Param (
        $InputObject
    )
    Try {
        $OutputObject = @()
        ForEach ($IP in $InputObject) {
            $OutputObject += New-IPAddressObject -IPaddress $([IPAddress]$IP) -ErrorAction Stop
            Write-Verbose "ConvertTo-IPaddress - Converted $IP to an IPAddress Object"
        }
        Return $OutputObject
    } Catch {
        $PSCmdlet.ThrowTerminatingError($PSitem)
    }
}