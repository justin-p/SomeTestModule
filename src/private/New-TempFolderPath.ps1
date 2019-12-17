Function New-TempFolderPath {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification="Just an Test Module")]
    Param()
    Return (Join-Path $env:TEMP (([System.Guid]::NewGuid() -split "-")[0]).ToString())
}