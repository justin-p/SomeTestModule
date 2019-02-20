Function Sync-DNObjectOnAllDomainControllers  {
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param (
        $InputObject,
        $SourceDomainController = $((Get-DomainController).dnshostname[0])
    )
    Write-Verbose "Sync-DNObjectOnAllDomainControllers - Syncing $InputObject"
    Try {
        Get-ADGroupMember 'Domain Controllers' | ForEach-Object {
            If ($InputObject.GetType().Name -eq "PSCustomObject") {
                Write-Debug "Sync-DNObjectOnAllDomainControllers - $($InputObject) type matched to PSCustomObject"
                If (!([string]::IsNullOrEmpty($InputObject))) {
                    Try {
                        [void](Sync-ADObject -object $InputObject -Source $SourceDomainController -Destination $_.Name)
                        [void](Get-ADObject -Identity $InputObject -Server $_.Name -ErrorAction Stop)
                    } Catch {
                        $PSCmdlet.ThrowTerminatingError($PSitem)
                    }
                }
            } ElseIf ($InputObject.GetType().Name -eq "Object[]") {
                Write-Debug "Sync-DNObjectOnAllDomainControllers - $($InputObject) type matched to Object[]. Starting ForEach."
                ForEach ($Value in $InputObject) {
                    If (!([string]::IsNullOrEmpty($Value))) {
                        Try {
                            [void](Sync-ADObject -object $Value -Source $SourceDomainController -Destination $_.Name)
                            [void](Get-ADObject -Identity $Value -Server $_.Name -ErrorAction Stop)
                        } Catch {
                            $PSCmdlet.ThrowTerminatingError($PSitem)
                       }
                    }
                }
            } ElseIf ($InputObject.GetType().Name -eq "String") {
                Write-Debug "Sync-DNObjectOnAllDomainControllers - $($InputObject) type matched to String"
                If (!([string]::IsNullOrEmpty($InputObject))) {
                    Try {
                        [void](Sync-ADObject -object $InputObject -Source $SourceDomainController -Destination $_.Name)
                        [void](Get-ADObject -Identity $InputObject -Server $_.Name -ErrorAction Stop)
                    } Catch {
                        $PSCmdlet.ThrowTerminatingError($PSitem)
                    }
                }
            }
        }
    } Catch {
        $PSCmdlet.ThrowTerminatingError($PSitem)
    }
}
#e