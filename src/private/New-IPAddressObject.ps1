Function New-IPAddressObject {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification="Just an Test Module")]
    Param(
        [IPAddress]$IPAddress
    )
    Return (New-Object PsObject -Property @{IPAddress = $IPAddress;})
}