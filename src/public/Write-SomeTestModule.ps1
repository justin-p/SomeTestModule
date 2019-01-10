function Write-SomeTestModule {
    <#
    .SYNOPSIS
    Simple sample function.
    .DESCRIPTION
    Simple sample function. Only Reason this is a thing is to test builds.
    .LINK
    https://github.com/justin-p/SomeTestModule
    .EXAMPLE
    Write-SomeTestModule
    .NOTES
    Author: Justin Perdok
    #>

    [CmdletBinding()]
    param(
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
