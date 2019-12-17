Function Test-ValueLength {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "", Justification="Just an Test Module")]
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $InputObject,
        $ElementToCheck,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $MaxLenght
    )
    $lenght = $null
    If ($InputObject.GetType().Name -eq "PSCustomObject") {
        Write-Verbose "Test-ValueLength - $($InputObject.$ElementToCheck) type matched to PSCustomObject"
        If (!([string]::IsNullOrEmpty($InputObject.$ElementToCheck))) {
                $lenght = $null
                $lenght = Get-StringLenght $InputObject.$ElementToCheck
                If ($lenght -gt $MaxLenght) {
                    Write-Error "Test-ValueLength - $($InputObject.$ElementToCheck) has a lenght of $lenght. This is longer MaxLenght of $MaxLenght"
                }
                Else {
                    Write-Verbose "Test-ValueLength - $($InputObject.$ElementToCheck) has a lenght of $lenght. This is not longer then MaxLenght of $MaxLenght"
                }
            }
    } ElseIf ($InputObject.GetType().Name -eq "Object[]") {
        Write-Verbose "Test-ValueLength - $($InputObject.$ElementToCheck) type matched to Object[]. Starting ForEach."
        ForEach ($Value in $InputObject) {
            If (!([string]::IsNullOrEmpty($Value.$ElementToCheck))) {
                $lenght = $null
                $lenght = Get-StringLenght $Value.$ElementToCheck
                If ($lenght -gt $MaxLenght) {
                    Write-Error "Test-ValueLength - $($Value.$ElementToCheck) has a lentgh of $lenght. This is longer then MaxLenght of $MaxLenght"
                } Else {
                    Write-Verbose "Test-ValueLength - $($Value.$ElementToCheck) has a lentgh of $lenght. This is not longer then MaxLenght of $MaxLenght"
                }
            } ElseIf ($null -eq $ElementToCheck) {
                $lenght = $null
                $lenght = Get-StringLenght $Value.$ElementToCheck
                If ($lenght -gt $MaxLenght) {
                    Write-Error "Test-ValueLength - $($Value) has a lentgh of $lenght. This is longer then MaxLenght of $MaxLenght"
                } Else {
                    Write-Verbose "Test-ValueLength - $($Value) has a lentgh of $lenght. This is not longer then MaxLenght of $MaxLenght"
                }
            }
        }
    } ElseIf ($InputObject.GetType().Name -eq "String") {
        Write-Verbose "Test-ValueLength - $($InputObject) type matched to String"
        $lenght = $null
        $lenght = Get-StringLenght $($InputObject)
        If ($lenght -gt $MaxLenght) {
            Write-Error "Test-ValueLength - $($InputObject) has a lentgh of $lenght. This is longer then MaxLenght of $MaxLenght"
        } Else {
            Write-Verbose "Test-ValueLength - $($InputObject) has a lentgh of $lenght. This is not longer then MaxLenght of $MaxLenght"
        }
    }
}