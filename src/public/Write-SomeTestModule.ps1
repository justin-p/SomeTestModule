Function Write-SomeTestModule {
    <#
    .SYNOPSIS
        A dummy test function
    .DESCRIPTION
        A dummy test function Displays a simply string as output
    .PARAMETER a
        a dummy param
    .EXAMPLE
        Write-SomeTestModule
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