Function Test-Url {
    [cmdletbinding()]
    Param (
        [System.URI]$url
    )
    Try {
        Invoke-WebRequest $url -ErrorAction Stop
    } Catch {
        Write-Error "Test-Url - $($PSItem). This could mean this domain contains a typo or the domain is simply not resolvable." -ErrorAction Stop
    }
}