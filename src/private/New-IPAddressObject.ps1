Function New-IPAddressObject {
    [CmdletBinding()]
    Param(
        [IPAddress]$IPAddress
    )
    Return (New-Object PsObject -Property @{IPAddress = $IPAddress;})
}