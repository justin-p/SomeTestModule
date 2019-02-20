Function Get-StringLenght {
  Param (
        [string]$string
  )
  Write-Verbose "Get-StringLenght - String lentgh is $($string.Length)"
  Return $string.Length
}