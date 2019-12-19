Function Write-SomeTestModule {
    <#
    .SYNOPSIS
    TBD
    .DESCRIPTION
    TBD
    .PARAMETER a
    a explanation
    .EXAMPLE
    TBD
    #>
    [CmdletBinding()]
    param(
        $a
    )
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
    }
    process {
        Write-Output 'Yerp. This is a function.'
    }
    end {
        Write-Verbose "$($FunctionName): End."
    }

}