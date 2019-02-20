Function New-TempFolderPath {
    Return (Join-Path $env:TEMP (([System.Guid]::NewGuid() -split "-")[0]).ToString())
}