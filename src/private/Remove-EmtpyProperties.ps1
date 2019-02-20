Function Remove-EmtpyProperties {
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline=$True)]
        $InputObject
    )
    Process {
        Write-Verbose "Remove-EmtpyProperties - Removing EmtpyProperties on `$InputObject"
        Write-Debug "Remove-EmtpyProperties - Iterate over objects"
        $InputObject | ForEach-Object {
            Write-Debug "Remove-EmtpyProperties - Get array of names of object properties that can be cast to boolean TRUE"
            # PSObject.Properties - https://msdn.microsoft.com/en-us/library/system.management.automation.psobject.properties.aspx
            $NonEmptyProperties = $_.psobject.Properties | Where-Object {$_.Value} | Select-Object -ExpandProperty Name
            Write-Debug "Remove-EmtpyProperties - Return only non-empty properties"
            $_ | Select-Object -Property $NonEmptyProperties
        }
    }
}